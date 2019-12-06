pragma solidity >=0.5.0 <0.6.0;
pragma experimental ABIEncoderV2;
import "https://github.com/tantv-918/Evi/blob/completeContract/contract/contracts/Evi.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/evm/v0.5/contracts/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/evm/v0.5/contracts/vendor/Ownable.sol";

contract EviFactory is ChainlinkClient{
  struct AllInsuranceOfBuyer{
    string[] allInsuranceId;
    uint8  exist;
  }

  struct InsurancePackage{
    string name;
    uint256 priceUSD;
    uint256 rate;
  }

  address payable manager = 0x8f287eA4DAD62A3A626942d149509D6457c2516C;

  mapping (address => AllInsuranceOfBuyer) public contractsOfBuyer;
  mapping (string => address) public idToContract;
  mapping (string => InsurancePackage) public insurancePackage;

  address[] public allCustomers;
  InsurancePackage[] allPackage;
  address public owner;
  uint256 public linkAmount = 30;

  constructor() public {
    owner = msg.sender;

    InsurancePackage memory pack1;
    pack1.name = "Silver";
    pack1.priceUSD = 1000;
    pack1.rate = 25;
    insurancePackage["Silver"] = pack1;
    allPackage.push(pack1);

    InsurancePackage memory pack2;
    pack1.name = "Gold";
    pack1.priceUSD = 5000;
    pack1.rate = 60;
    insurancePackage["Gold"] = pack2;
    allPackage.push(pack2);

    InsurancePackage memory pack3;
    pack1.name = "Platinum";
    pack1.priceUSD = 10000;
    pack1.rate = 100;
    insurancePackage["Platinum"] = pack3;
    allPackage.push(pack3);
  }

  event contractDeployed(
    address Evi
  );

  event AddPackage(
    bool success
  );

  modifier onlyManager(){
		require(msg.sender == manager, "Unauthorised , must be manager");
		_;
	}

  function createEvi(
    string memory _insuranceId,
    string memory _location,
    string memory _date,
    string memory _times,
    uint256 _priceWei,
    string memory _packageName,
    address _link
  ) public payable {
    require(msg.value >= _priceWei, "Not Enough Money");

    uint256 rate = insurancePackage[_packageName].rate;

    address payable packageInsurance = address(new Evi(msg.sender, _location, _date, _times, _priceWei, rate, linkAmount ,_link));

    idToContract[_insuranceId] = packageInsurance;

    packageInsurance.transfer(msg.value);

    LinkTokenInterface link = LinkTokenInterface(0x20fE562d797A42Dcb3399062AE9546cd06f63280);
    link.transfer(packageInsurance, linkAmount * LINK);

    if(contractsOfBuyer[msg.sender].exist != 1){
      contractsOfBuyer[msg.sender].allInsuranceId.push(_insuranceId);
      contractsOfBuyer[msg.sender].exist = 1;
      allCustomers.push(msg.sender);

    } else {
      contractsOfBuyer[msg.sender].allInsuranceId.push(_insuranceId);
    }

    emit contractDeployed(packageInsurance);
  }

  function getAllContract(address _buyer) public view returns(string[] memory) {
    require(msg.sender == _buyer || msg.sender == manager, "Permission Denided !");
    return contractsOfBuyer[_buyer].allInsuranceId;
  }

  function getContractAddress(string memory _insuranceId) public view returns(address){
    return idToContract[_insuranceId];
  }

  function getAllCustomer() public view onlyManager returns(address[] memory) {
    return allCustomers;
  }

  function getInsurancePackage(string memory _name) public view onlyManager returns(string memory, uint256, uint256) {
    return (insurancePackage[_name].name, insurancePackage[_name].priceUSD, insurancePackage[_name].rate);
  }

  function addInsurancePackage(string memory _name, uint256 _priceUSD, uint256 rate) public onlyManager {
    InsurancePackage memory package;

    package.name = _name;
    package.priceUSD = _priceUSD;
    package.rate = rate;

    insurancePackage[_name] = package;
    allPackage.push(package);

    emit AddPackage(true);
  }

  function setLINKAmount(uint256 _linkAmount) public onlyManager {
    linkAmount = _linkAmount;
  }

  // function getAllInsurancePackage() public view onlyManager returns(string[] memory, uint256[], uint256[]){
  //   //return allPackage;
  // }
  function() external payable {}
}
