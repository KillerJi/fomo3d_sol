// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "hardhat/console.sol";

contract fomo3d {
    using SafeMath for uint256;

    enum group {
        one,
        two,
        three
    }

    address public owner;
    uint256 public key_init_price;
    uint256 public key_final_price;
    uint256 public key_increasing_price;
    uint256 public rounds;
    mapping(uint256 => uint256) public start_time;
    mapping(uint256 => uint256) public end_time;
    mapping(address => mapping(uint256 => group)) public team;
    mapping(address => uint256) private _nonce;

    bytes32 public DOMAIN_SEPARATOR;

    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            bytes(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            )
        );
    bytes32 public constant VAULTBUY_TRANSACTION_TYPEHASH =
        keccak256(
            bytes(
                "VaultBuy(uint256 buy_num,uint256 team,uint256 rounds,address account,uint256 nonce)"
            )
        );
    bytes32 public constant CLAIM_TRANSACTION_TYPEHASH =
        keccak256(
            bytes("Claim(address _account,uint256 _number,uint256 nonce)")
        );

    event BnbBuy(
        address account,
        uint256 bnbvalue,
        uint256 buy_num,
        group team,
        uint256 rounds
    );
    event VaultBuy(
        address account,
        uint256 vaultvalue,
        uint256 buy_num,
        group team,
        uint256 rounds
    );
    event Claim(address account, uint256 claimvalue);

    constructor(address _owner) {
        owner = _owner;
        key_init_price = 0.01 * 1e18;
        key_final_price = 0.01 * 1e18;
        key_increasing_price = 0.00002 * 1e18;
        rounds = 1;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("Fomo3d")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        console.log("chainId", chainId);
        console.log("owner", owner);
        console.log("contract ", address(this));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setActionTime(uint256 _time) external onlyOwner {
        require(
            _time > block.timestamp,
            "Set time must be greater than the current time"
        );
        start_time[rounds] = _time;
        end_time[rounds] = block.timestamp.add(24 * 60 * 20 * 3);
    }

    function nonceOf(address account) public view returns (uint256) {
        return _nonce[account];
    }

    function _buy_key(
        uint256 _buy_num,
        group _team,
        uint64 _rounds
    ) internal {
        require(_rounds == rounds, "rounds error");
        if (block.timestamp >= end_time[_rounds]) {
            rounds = rounds.add(1);
            end_time[rounds] = block.timestamp.add(24 * 60 * 20 * 3);
            key_final_price = key_init_price;
        } else {
            team[msg.sender][rounds] = _team;
            uint256 final_key_price = key_increasing_price.mul(_buy_num);
            uint256 final_num = final_key_price.add(key_final_price);
            key_final_price = final_key_price;
            final_num = final_num.mul(_buy_num);
            final_num = final_num.div(2);
            require(final_num == msg.value, "Insufficient payment");
            end_time[rounds] = block.timestamp.add(24 * 60 * 20 * 3);
        }
    }

    function bnbBuy(
        uint256 _buy_num,
        group _team,
        uint64 _rounds
    ) external payable {
        _buy_key(_buy_num, _team, _rounds);
        emit BnbBuy(msg.sender, msg.value, _buy_num, _team, _rounds);
    }

    function vaultBuy(
        uint256 _buy_num,
        uint256 _team,
        uint256 _rounds,
        address _account,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        console.log("vault buy                   1!!!!!");
        console.log("_buy_num ", _buy_num);
        // console.log(_team == group.two);
        console.log("_team ", _team);
        console.log("_rounds ", _rounds);
        console.log("_account ", _account);
        console.log("nonce ", nonce);
        // console.log(
        //     "abi ",
        //     abi.encode(
        //         VAULTBUY_TRANSACTION_TYPEHASH,
        //         _buy_num,
        //         _team,
        //         _rounds,
        //         _account,
        //         nonce
        //     )
        // );
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        VAULTBUY_TRANSACTION_TYPEHASH,
                        _buy_num,
                        _team,
                        _rounds,
                        _account,
                        nonce
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        console.log("vault buy                   1!!!!!");
        console.log(recoveredAddress);
        console.log(owner);
        // require(
        //     recoveredAddress == owner &&
        //         _account == msg.sender &&
        //         _buy_num > uint256(0) &&
        //         _rounds > uint256(0) &&
        //         nonce > _nonce[_account]
        // );
        // _buy_key(_buy_num, _team, _rounds);
        _nonce[_account]++;

        // emit VaultBuy(msg.sender, msg.value, _buy_num, _team, _rounds);
    }

    function claim(
        address payable _account,
        uint256 _number,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        CLAIM_TRANSACTION_TYPEHASH,
                        _account,
                        _number,
                        nonce
                    )
                )
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress == owner &&
                _account == msg.sender &&
                _number > uint256(0) &&
                nonce > _nonce[_account]
        );

        _nonce[_account]++;
        _account.transfer(_number);
        emit Claim(msg.sender, _number);
    }
}
