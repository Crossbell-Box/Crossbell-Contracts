// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.18;

import {Events} from "./Events.sol";
import {ILinklist} from "../interfaces/ILinklist.sol";
import {ErrLinkTypeExists} from "./Error.sol";

library LinklistLogic {
    function setLinklistUri(uint256 linklistId, string calldata uri, address linklist) external {
        ILinklist(linklist).setUri(linklistId, uri);
    }

    function setLinklistType(
        uint256 characterId,
        uint256 linklistId,
        bytes32 linkType,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        // check linklist exists
        if (0 != _attachedLinklists[characterId][linkType])
            revert ErrLinkTypeExists(characterId, linkType);

        // detach linklist
        bytes32 oldLinkType = ILinklist(linklist).getLinkType(linklistId);
        emit Events.DetachLinklist(linklistId, characterId, oldLinkType);

        // attach linklist
        _attachedLinklists[characterId][linkType] = linklistId;
        emit Events.AttachLinklist(linklistId, characterId, linkType);

        // set linklist type
        ILinklist(linklist).setLinkType(linklistId, linkType);
    }

    function burnLinklist(
        uint256 characterId,
        uint256 linklistId,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        // delete _attachedLinklist
        bytes32 linkType = ILinklist(linklist).getLinkType(linklistId);
        delete _attachedLinklists[characterId][linkType];

        // burn linklist
        ILinklist(linklist).burn(linklistId);
    }
}
