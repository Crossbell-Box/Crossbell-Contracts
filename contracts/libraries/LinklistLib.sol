// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.18;

import {Events} from "./Events.sol";
import {ErrLinkTypeExists} from "./Error.sol";
import {StorageLib} from "./StorageLib.sol";
import {ILinklist} from "../interfaces/ILinklist.sol";

library LinklistLib {
    function setLinklistUri(uint256 linklistId, string calldata uri, address linklist) external {
        ILinklist(linklist).setUri(linklistId, uri);
    }

    function setLinklistType(
        uint256 characterId,
        uint256 linklistId,
        bytes32 linkType,
        address linklist
    ) external {
        // check linklist exists
        if (0 != StorageLib.getAttachedLinklistId(characterId, linkType))
            revert ErrLinkTypeExists(characterId, linkType);

        // detach linklist
        bytes32 oldLinkType = ILinklist(linklist).getLinkType(linklistId);
        // set linklistId to 0
        StorageLib.setAttachedLinklistId(characterId, oldLinkType, 0);
        emit Events.DetachLinklist(linklistId, characterId, oldLinkType);

        // attach linklist
        StorageLib.setAttachedLinklistId(characterId, linkType, linklistId);
        emit Events.AttachLinklist(linklistId, characterId, linkType);

        // set linklist type
        ILinklist(linklist).setLinkType(linklistId, linkType);
    }

    function burnLinklist(uint256 characterId, uint256 linklistId, address linklist) external {
        bytes32 linkType = ILinklist(linklist).getLinkType(linklistId);
        // delete _attachedLinklist (set linklistId to 0)
        StorageLib.setAttachedLinklistId(characterId, linkType, 0);

        // burn linklist
        ILinklist(linklist).burn(linklistId);
    }
}
