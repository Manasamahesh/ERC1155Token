pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract ERC1155MarketPlace is ERC1155,Ownable {
    struct TokenRoyaltyDetials {
        address payable recipient;
        uint256 tokenName;
        uint256 amount;
    }
    mapping(uint256 => TokenRoyaltyDetials) internal _royaltyDetail;
    uint256 public constant FungileToken = 0;
    uint256 public constant skypicture = 1;
    uint256 public constant sunlightDeviation = 2;
    uint256 public constant christmas =3;
    string private _uri;
    mapping(uint256 => string) private _uris;
    mapping(uint256 => mapping(address => uint256)) _balances ;
    
    event Platformfee(address payable miner, uint256 calculateplatformfees);
    event Royaltyfee(address payable royaltiesrecipient, uint256 royaltyAmount);
    constructor() ERC1155 ("https://bafybeicvss3qiexx4srl7junjd3auqrs4gsz5mtgolxofjae2dxwdu2iam.ipfs.dweb.link/{tokenId}.json") {
        _mintForFungileToken(FungileToken, 10**18);
        _mint(msg.sender,skypicture,2000,"");
        _mint(msg.sender,sunlightDeviation,1000,"");
        _mint(msg.sender,christmas,1300,"");
      } 

    function _mintForFungileToken (uint256 tokenId, uint256 _price)  
     private onlyOwner returns (bool) {
      _balances[tokenId][msg.sender] = _price;
     _mint(msg.sender, tokenId, _price,"");
      return true;
    }


        function _safeBatchTransferFrom(
        address seller,
        address buyer,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
         super._safeBatchTransferFrom(seller, buyer, tokenIds, amounts, data);
        _validateDetials(tokenIds,amounts);
        _transferplatformFee(seller,tokenIds,amounts);
        _setRoyal(tokenIds,amounts);
      }
        function _validateDetials(uint256[] memory tokenIds,uint256[] memory  amounts) internal {
                for (uint256 i = 0; i < tokenIds.length; i++) {
                    uint256 tokenId = tokenIds[i];
                    uint256 amount = amounts[i];
                    require(bytes(_uris[tokenId]).length == 0,"Error,product is not present in the ledger");
                    require(msg.value < amount,"Error, Insufficient balance to purchase this product");
                } 
        }

        function _transferplatformFee ( address seller, uint256[] memory tokenIds,uint256[] memory  amounts) internal{
            for (uint256 i = 0; i< tokenIds.length;i++) {
                uint256 amount = amounts[i];
                uint256 calculateplatformfees = (( uint256(25)/uint256(10))*(amount))/uint256(100);
                require( _balances[0][seller] >= calculateplatformfees,"Error, there is no enough platform fee for transfer");
                 _balances[0][seller] -= calculateplatformfees;
                block.coinbase.transfer(calculateplatformfees);
                emit Platformfee(block.coinbase,calculateplatformfees);
            }
        }

        function _setRoyal (uint256[] memory tokenIds, uint256[] memory  amounts) internal{
          for (uint256 i = 0; i< tokenIds.length;i++) {
              uint256 tokenId = tokenIds[i];
              uint256 amount = amounts[i];
              TokenRoyaltyDetials memory royalties = _royaltyDetail[tokenId];
               uint256 royaltyAmount = (amount * 1/16);
               require(_balances[0][msg.sender] >= royaltyAmount,"Error, there is no enough amount for paying platform fees");
               royalties.recipient.transfer(royaltyAmount);
               emit Royaltyfee(royalties.recipient,royaltyAmount);
          }
        }
}