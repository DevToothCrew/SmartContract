pragma solidity ^0.5.3;

// Made By Tom

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        
        return c;       
    }       

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract OwnerHelper
{
    address public owner;
    
    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public
    {
        owner = msg.sender;
    }
    
    function transferOwnership(address _to) public returns (bool)
    {
        require(_to != owner);
        require(_to != address(0x0));
        owner = _to;
    }
}

contract PublicSale is OwnerHelper {
    
    using SafeMath for uint;
    
    uint public saleEthCount = 0;
    uint constant public minEth = 1 ether;
    mapping (address => uint) public userEthCount;

    constructor() public 
    {
        owner = msg.sender;
    }

    function () payable external
    {
        require(msg.value >= minEth);
   
        saleEthCount = saleEthCount.add(msg.value);
        userEthCount[msg.sender] = userEthCount[msg.sender].add(msg.value);
    }

    function withdraw() public onlyOwner 
    {
        msg.sender.transfer(saleEthCount);
    }
}
