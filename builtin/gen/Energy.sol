pragma solidity ^0.4.18;
import "./Token.sol";
import "./ERC223Receiver.sol";
import "./Prototype.sol";

/// @title Energy an token that represents fuel for VET.
contract Energy is Token {
    mapping(address => mapping (address => uint256)) allowed;

    ///@return ERC20 token name
    function name() public pure returns (string) {
        return "VeThor";
    }

    ///@return ERC20 token decimals
    function decimals() public pure returns (uint8) {
        return 18;    
    }

    ///@return ERC20 token symbol
    function symbol() public pure returns (string) {
        return "VTHO";
    }

    ///@return ERC20 token total supply
    function totalSupply() public constant returns (uint256) {
        return EnergyNative(this).native_getTotalSupply();
    }

    function totalBurned() public constant returns(uint256) {
        return EnergyNative(this).native_getTotalBurned();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return EnergyNative(this).native_getBalance(_owner);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        if (_amount > 0) {
            require(EnergyNative(this).native_subBalance(_from, _amount));

            // believed that will never overflow
            EnergyNative(this).native_addBalance(_to, _amount);
        }
    
        if (isContract(_to)) {
            // Require proper transaction handling.
            ERC223Receiver(_to).tokenFallback(_from, _amount, new bytes(0));
        }
        Transfer(_from, _to, _amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from,address _to,uint256 _amount) public returns(bool success) {
        require(allowed[_from][_to] >= _amount);
        allowed[_from][_to] -= _amount;

        _transfer(_from, _to, _amount);        
        return true;
    }

    function allowance(address _owner, address _spender)  public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _reciever, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_reciever] = _amount;
        Approval(msg.sender, _reciever, _amount);
        return true;
    }

    /// @notice the contract owner approves `_contractAddr` to transfer `_amount` tokens to `_to`
    /// @param _contractAddr The address of the contract able to transfer the tokens
    /// @param _to who receive the `_amount` tokens
    /// @param _amount The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function transferFromContract(address _contractAddr, address _to, uint256 _amount) public returns (bool success) {
        require(msg.sender == PrototypeNative(_contractAddr).prototype_master());        
        _transfer(_contractAddr, _to, _amount);
        return true;
    } 
    
    /// @param _addr an address of a normal account or a contract
    /// 
    /// @return whether `_addr` is a contract or not
    function isContract(address _addr) view internal returns(bool) {        
        if (_addr == 0) {
            return false;
        }
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

contract EnergyNative {
    function native_getTotalSupply() public view returns(uint256);
    function native_getTotalBurned() public view returns(uint256);
    
    function native_getBalance(address addr) public view returns(uint256);
    function native_addBalance(address addr, uint256 amount) public;
    function native_subBalance(address addr, uint256 amount) public returns(bool);
}