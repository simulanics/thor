pragma solidity ^0.4.18;

contract Params {

    function executor() public view returns(address) {
        return ParamsNative(this).native_getExecutor();
    }

    function set(bytes32 _key, uint256 _value) public {
        require(msg.sender == executor());

        ParamsNative(this).native_set(_key, _value);
        Set(_key, _value);
    }

    function get(bytes32 _key) public view returns(uint256) {
        return ParamsNative(this).native_get(_key);
    }

    event Set(bytes32 indexed key, uint256 value);
}

contract ParamsNative {
    function native_getExecutor() public view returns(address);

    function native_set(bytes32 key, uint256 value) public;
    function native_get(bytes32 key) public view returns(uint256);
}