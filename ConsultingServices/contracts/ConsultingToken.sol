// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./token/ERC721/ERC721.sol";

/*
Blockchain Consulting
Motivation
Suppose you would like to offer your special knowledge and services as a consultant, 
but you don’t want to waste a lot of time on the business aspects of payment coordination and marketing.  
This NFT-based business gives you an easy way to sell your time and knowledge services for money, 
even if you don’t know just how much you should charge or how to get the word out.

The solution will allow to a Host (Consultant) to define NFTs for his services. 
The host can include information such as topic and time slot (start time and end time) for each appointment. 
The attendees require to have a NFT to attend the service. An attendee can resell a token for a consultant service and
increase its value.To attend the service, the attendee has to sign a particular message to demonstrate the use of the NFT. 
The attendee only can host the event in the time slot defined by the host.
*/

contract ConsultingToken is ERC721("ConsultingToken", "CNS") {
    uint256 public time = block.timestamp;

    enum DeliveredStatus {FOR_SALE, SOLD, RELEASE}

    struct ConsultingService {
        uint256 id;
        string topic;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        string hostName;
        bool hostCheckedIn;
        DeliveredStatus status;
        address payable host;
        address payable owner;
    }

    //Array of consultingServices
    ConsultingService[] private consultingServices;

    //Mapping consultingServices vs tokenId
    mapping(uint256 => ConsultingService) public tokens;

    modifier onlyOwner(uint256 _tokenId) {
        require(
            msg.sender == (super.ownerOf(_tokenId)),
            "ConsultingService: not owner of the token"
        );
        _;
    }

    modifier validStatus(DeliveredStatus _status, uint256 _tokenId) {
        ConsultingService memory consultingService = tokens[_tokenId];
        require(consultingService.status == _status);
        _;
    }

    //Create a token
    function createConsultingService(
        string memory _topic,
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        string memory _hostName
    ) public {
        require(
            bytes(_topic).length > 0,
            "ConsultingService: The topic cannot be empty"
        );
        require(_price > 0, "ConsultingService: The price cannot be zero");
        require(
            _startTime > 0,
            "ConsultingService: The start time cannot be zero"
        );
        require(_endTime > 0, "ConsultingService: The end time cannot be zero");
        require(
            bytes(_hostName).length > 0,
            "ConsultingService: The host name cannot be empty"
        );
        require(
            _endTime > _startTime,
            "ConsultingService: end time is before start time"
        );

        ConsultingService memory _consultingService =
            ConsultingService({
                id: 0,
                topic: _topic,
                price: _price,
                startTime: _startTime,
                endTime: _endTime,
                hostName: _hostName,
                hostCheckedIn: false,
                status: DeliveredStatus.FOR_SALE,
                host: msg.sender,
                owner: msg.sender
            });

        consultingServices.push(_consultingService);

        uint256 tokenId = consultingServices.length - 1;

        //Mint the token
        _safeMint(msg.sender, tokenId);

        uint256 _index = tokenId;
        consultingServices[_index].id = _index;

        _consultingService.id = _index;
        tokens[tokenId] = _consultingService;
    }

    //Consult total of services
    function totalConsultingServices() public view returns (uint256) {
        return super.totalSupply();
    }

    //Consult the owner of a token
    function ownerOfToken(uint256 _tokenId) public view returns (address) {
        return super.ownerOf(_tokenId);
    }

    //Consult the balance of an address
    function balanceOfAddress(address _owner) public view returns (uint256) {
        return super.balanceOf(_owner);
    }

    //Approve to transfer a token
    function approveTransferToken(address _attendee, uint256 _tokenId)
        public
        onlyOwner(_tokenId)
        validStatus(DeliveredStatus.FOR_SALE, _tokenId)
    {
        require(_attendee != address(0x0));

        ConsultingService memory consultingService = tokens[_tokenId];

        super.approve(_attendee, _tokenId);

        emit Approval(consultingService.owner, _attendee, _tokenId);
    }

    //Approve to transfer all tokens to an address
    function approvalTransferTokenForAll(address _attendee) public 
    {
        require(_attendee != address(0x0));

        super.setApprovalForAll(_attendee, true);

        emit ApprovalForAll(msg.sender, _attendee, true);
    }

    //Validate if a token exists
    function existsToken(uint256 _tokenId) internal view returns (bool) 
    {
        return (!(tokens[_tokenId].price == 0));
    }

    //Buy a consulting service
    function buyConsultingService(uint256 _tokenId)
        public
        payable
        validStatus(DeliveredStatus.FOR_SALE, _tokenId)
    {
        require(existsToken(_tokenId), "ConsultingService: nonexistant token");

        ConsultingService memory consultingService = tokens[_tokenId];

        uint256 index = consultingService.id;

        bool _isApprovedOrOwner =
            (super.getApproved(_tokenId) == msg.sender ||
                super.isApprovedForAll(consultingService.owner, msg.sender));

        require(
            _isApprovedOrOwner,
            "ConsultingService: the owner does not approve"
        );
        require(
            msg.value >= consultingService.price,
            "ConsultingService: it is not enough the value "
        );
        require(
            msg.sender != address(0),
            "ConsultingService: the buyer has an address zero"
        );

        //Transfer the token
        if (msg.value > consultingService.price) {
            msg.sender.transfer(msg.value - consultingService.price);
        }

        consultingService.owner.transfer(consultingService.price);
        super.transferFrom(consultingService.owner, msg.sender, _tokenId);

        emit Transfer(consultingService.owner, msg.sender, _tokenId);

        tokens[_tokenId].owner = msg.sender;
        tokens[_tokenId].status = DeliveredStatus.SOLD;

        consultingServices[index].owner = msg.sender;
        consultingServices[index].status = DeliveredStatus.SOLD;
    }

    //Resell a consulting service
    function resellConsultingService(uint256 _tokenId, uint256 _price)
        public
        payable
        onlyOwner(_tokenId)
        validStatus(DeliveredStatus.SOLD, _tokenId)
    {
        require(msg.sender != address(0));
        require(existsToken(_tokenId), "ConsultingService: nonexistant token");

        require(_price > 0);
        ConsultingService memory consultingService = tokens[_tokenId];
        uint256 index = consultingService.id;

        tokens[_tokenId].status = DeliveredStatus.FOR_SALE;
        tokens[_tokenId].price = _price;

        consultingServices[index].status = DeliveredStatus.FOR_SALE;
        consultingServices[index].price = _price;
    }

    //Release a token after a slot of time (attend the consultant service)
    function releaseStatus(uint256 _tokenId)
        public
        onlyOwner(_tokenId)
        validStatus(DeliveredStatus.SOLD, _tokenId)
    {
        require(existsToken(_tokenId), "ConsultingService: nonexistant token");

        ConsultingService memory consultingService = tokens[_tokenId];
        uint256 index = consultingService.id;

        require(
            block.timestamp > consultingService.startTime,
            "ConsultingService: current time is before release time"
        );

        if (consultingService.startTime <= block.timestamp) {
            tokens[_tokenId].status = DeliveredStatus.RELEASE;
            tokens[_tokenId].hostCheckedIn = true;

            consultingServices[index].status = DeliveredStatus.RELEASE;
            consultingServices[index].hostCheckedIn = true;
        }
    }
}
