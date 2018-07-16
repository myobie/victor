import {
  closestSegment,
  contentToState,
  indexOfChild,
  isAbove,
  isBelow,
  isSibling,
  isLastItemIn,
  prevSiblingPath
} from './helpers'

export function sidebarStore (globalState, emitter) {
  if (globalState.sidebar === undefined) { globalState.sidebar = {} }
  const state = globalState.sidebar

  state.db = contentToState(globalState.content)

  state.selectedItem = null

  resetDragging() // start out resetted

  emitter.on('sidebar:dragstart', path => {
    state.isDragging = true
    state.dragging.from = path
    state.dragging.fromItem = findItem(path)
    render()
  })

  emitter.on('sidebar:dragover', segment => {
    if (!state.isOver) { return }
    processDragOver(segment)
    render()
  })

  emitter.on('sidebar:dragenter', path => {
    state.isOver = true
    state.dragging.over = path
    state.dragging.overItem = findItem(path)
    render()
  })

  emitter.on('sidebar:dragleave', path => {
    state.isOver = false
    state.dragging.overMouseSegment = null
    render()
  })

  emitter.on('sidebar:drop', ({ path, data }) => {
    performPatch()
    // dragend will render
  })

  emitter.on('sidebar:dragend', () => {
    resetDragging()
    render()
  })

  emitter.on('sidebar:select', item => {
    state.selectedItem = item
    render()
  })

  emitter.on('sidebar:deselect', () => {
    state.selectedItem = null
    render()
  })

  function render () { return emitter.emit('render') }

  function resetDragging () {
    state.isDragging = false
    state.isOver = false

    state.dragging = {
      from: null,
      fromItem: null,
      over: null,
      overItem: null,
      overMouseSegment: null,
      overSegment: null,
      dropPatch: {}
    }
  }

  function processDragOver (segment) {
    let lowestSegment = null
    let highestSegment = null
    let overSegment = null
    let patch = {}

    const fromPath = state.dragging.from
    const overPath = state.dragging.over
    const parentPath = overPath.slice(0, -1)

    const overCurrentLevel = overPath.length - 1

    const over = findItem(overPath)
    const prev = prevSiblingItem(overPath)
    const prevPath = prevSiblingPath(overPath)
    const parent = findItem(parentPath)

    if (isAbove(fromPath, overPath)) {
      // from above
      if (over.type === 'group') {
        // must put it into the group if coming from above (will end up being the first item in the group)
        highestSegment = lowestSegment = overCurrentLevel + 1

        // determine the necessary patch if we drop here
        patch = { prependTo: overPath } // prepend to the group we are over
      } else if (parent && parent.type === 'group' && isLastItemIn(parent, over)) {
        // if the parent is a group and the item we are over is the last item then we can exit the group or we can be the last item of the group
        lowestSegment = overCurrentLevel - 1
        highestSegment = overCurrentLevel

        // determine the necessary patch if we drop here
        overSegment = closestSegment(lowestSegment, highestSegment, segment)

        if (overSegment === lowestSegment) {
          patch = { insertAt: parentPath, type: 'after' } // insert after the group we are exiting
        } else {
          patch = { insertAt: overPath, type: 'after' } // insert after the item we are over
        }
      } else {
        // else we must simply replace the item we are over at it's same level
        lowestSegment = highestSegment = overCurrentLevel

        // determine the necessary patch if we drop here
        patch = { insertAt: overPath, type: 'after' } // insert after the item we are over
      }
    } else if (isBelow(fromPath, overPath)) {
      // from below
      if (prev && prev.type === 'group') {
        // if the item directly before us is a group, then we can enter the group as it's last item or simply replace the item we are over
        lowestSegment = overCurrentLevel
        highestSegment = overCurrentLevel + 1

        // determine the necessary patch if we drop here
        overSegment = closestSegment(lowestSegment, highestSegment, segment)

        if (overSegment === highestSegment) {
          patch = { appendTo: prevPath } // append to the group that is right above us
        } else {
          patch = { insertAt: overPath, type: 'before' } // insert before the item we are over
        }
      } else {
        // else we must simply replace the item we are over at it's same level
        lowestSegment = highestSegment = overCurrentLevel

        // determine the necessary patch if we drop here
        patch = { insertAt: overPath, type: 'before' } // insert before the item we are over
      }
    } else {
      // same item
      if (prev && prev.type === 'group') {
        // if the item directly above us is a group, then we can enter that group as it's last item or we can stay where we are at right now
        lowestSegment = overCurrentLevel
        highestSegment = overCurrentLevel + 1

        // determine the necessary patch if we drop here
        overSegment = closestSegment(lowestSegment, highestSegment, segment)

        if (overSegment === highestSegment) {
          patch = { appendTo: prevPath } // append to the previous item's children
        } else {
          // nothing to patch
        }
      } else if (parent && parent.type === 'group' && isLastItemIn(parent, over)) {
        // if the parent is a group and the we are the last item then we can exit the group or we can remain as the last item of the group
        lowestSegment = overCurrentLevel - 1
        highestSegment = overCurrentLevel

        // determine the necessary patch if we drop here
        overSegment = closestSegment(lowestSegment, highestSegment, segment)

        if (overSegment === lowestSegment) {
          patch = { insertAt: parentPath, type: 'after' } // insert after the group we are exiting
        } else {
          // nothing to patch
        }
      } else {
        // else we must simply stay where we are
        lowestSegment = highestSegment = overCurrentLevel

        // nothing to patch
      }
    }

    if (overSegment === null) {
      overSegment = closestSegment(lowestSegment, highestSegment, segment)
    }

    state.dragging.overMouseSegment = segment
    state.dragging.overSegment = overSegment
    state.dragging.dropPatch = patch
  }

  function performPatch () {
    if (!state.dragging.dropPatch) { return }

    const patch = state.dragging.dropPatch

    if (!(patch.insertAt || patch.appendTo || patch.prependTo)) { return }

    const patchPath = patch.insertAt || patch.prependTo || patch.appendTo
    const patchItem = findItem(patchPath)
    const patchParent = findParent(patchPath)
    const patchItemEndIndex = patchPath[patchPath.length - 1]

    const fromPath = state.dragging.from
    const fromItem = findItem(fromPath)
    const fromParent = findParent(fromPath)
    const fromItemEndIndex = fromPath[fromPath.length - 1]

    if (patch.appendTo) {
      const endIndex = patchItem.children.length
      patchItem.children.splice(endIndex, 0, fromItem) // insert at the end of the patch because it is the new group
      fromParent.children.splice(fromItemEndIndex, 1) // remove
    } else if (patch.prependTo) {
      patchItem.children.splice(0, 0, fromItem) // insert at the beginning of the patch because it is the new group
      fromParent.children.splice(fromItemEndIndex, 1) // remove
    } else if (patch.insertAt) {
      let insertIndex
      if (patch.type === 'before') { insertIndex = patchItemEndIndex }
      if (patch.type === 'after') { insertIndex = patchItemEndIndex + 1 }

      if (isSibling(patchPath, fromPath)) {
        // if we are in the same group, then we do a swap with a placeholder so
        // the order doesn't change before we re-insert so we don't have to
        // re-calc where the insert may have moved to becuase of the removal or
        // is that just confusing?

        const placeholder = { _cid: 'placeholder' }

        const removedItem = patchParent.children.splice(fromItemEndIndex, 1, placeholder)[0] // remove the current dragged item and insert a placeholder so the order doesn't change yet
        patchParent.children.splice(insertIndex, 0, removedItem) // insert according to the patch

        const placeholderIndex = indexOfChild(patchParent, placeholder) // now find the placeholder
        patchParent.children.splice(placeholderIndex, 1) // and remove it
      } else {
        patchParent.children.splice(insertIndex, 0, fromItem) // insert
        fromParent.children.splice(fromItemEndIndex, 1) // remove
      }
    }
  }

  function findParent (path) {
    path = path.slice(0, -1) // everything except the last item
    return findItem(path)
  }

  function findItem (path) {
    let item = state.db
    let scope = item.children

    for (let i of path) {
      if (!Array.isArray(scope)) { return null }

      item = scope[i]

      if (item) {
        scope = item.children
      } else {
        return null
      }
    }

    return item
  }

  function prevSiblingItem (path) {
    const prevPath = prevSiblingPath(path)

    if (!prevPath) { return null }

    return findItem(prevPath)
  }
}
