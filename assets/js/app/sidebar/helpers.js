export function contentToState (content, sortType) {
  const root = {
    type: 'root',
    id: '_root',
    title: getTitle(content),
    children: gatherChildren(content, sortType)
  }

  return root
}

function gatherChildren (item, sortType) {
  let children = []

  if (Array.isArray(item.sections)) {
    for (let section of item.sections) {
      children.push({
        type: 'group',
        id: section.id,
        title: getTitle(section),
        children: gatherChildren(section),
        _cid: section._cid
      })
    }
  }

  if (Array.isArray(item.pages)) {
    for (let page of item.pages) {
      children.push({
        type: 'item',
        id: page.id,
        title: getTitle(page),
        _cid: page._cid
      })
    }
  }

  if (sortType === 'parent-frontmatter') {
    sortByParentFrontmatter(children, {})
  } else if (sortType === 'weight') {
    sortByWeight(children, {})
  } else {
    sortById(children)
  }

  return children
}

function getTitle (item) {
  const title = item.markdown && item.markdown.frontmatter && item.markdown.frontmatter.title
  return title || item.id || 'Group'
}

function sortById (children) {
  children.sort((a, b) => {
    if (a.id > b.id) { return 1 }
    if (a.id < b.id) { return -1 }
    return 0
  })
}

function sortByParentFrontmatter (children, parent) {
  throw new Error('cannot sort by parent frontmatter yet')
}

function sortByWeight (children, weights) {
  throw new Error('cannot sort by weight yet')
}

export function isItemWithCID (item, cid) {
  return item._cid === cid
}

export function isSameItem (left, right) {
  return left._cid === right._cid
}

export function compareCID (cid) {
  return item => { return isItemWithCID(item, cid) }
}

export function compareItem (item) {
  return compareCID(item._cid)
}

export function closestSegment (lowest, highest, desired) {
  if (desired < lowest) {
    return lowest
  }

  if (desired > highest) {
    return highest
  }

  return desired
}

export function isSibling (left, right) {
  if (left.length !== right.length) { return false }

  left = left.slice(0, -1) // everything except the last item
  right = right.slice(0, -1) // everything except the last item

  return isArrayEqual(left, right)
}

export function isLastItemIn (parent, child) {
  if (!Array.isArray(parent.children)) { return false }

  const actualLastChild = parent.children[parent.children.length - 1]

  return isSameItem(child, actualLastChild)
}

export function indexOfChild (parent, item) {
  return parent.children.findIndex(compareItem(item))
}

export function isAbove (first, second) {
  if (!Array.isArray(first) || !Array.isArray(second)) { return false }

  const count = Math.min(first.length, second.length)
  const lastIndex = count - 1

  for (let i = 0; i < count; ++i) {
    const a = first[i]
    const b = second[i]

    if (lastIndex === i && a === b && first.length >= second.length) { return false }
    if (a > b) { return false }
  }

  return true
}

export function isAboveOrEqual (first, second) {
  if (!Array.isArray(first) || !Array.isArray(second)) { return false }

  const count = Math.min(first.length, second.length)
  const lastIndex = count - 1

  for (let i = 0; i < count; ++i) {
    const a = first[i]
    const b = second[i]

    if (lastIndex === i && a === b && first.length > second.length) { return false }
    if (a > b) { return false }
  }

  return true
}

export function isBelow (first, second) {
  if (!Array.isArray(first) || !Array.isArray(second)) { return false }

  const count = Math.min(first.length, second.length)
  const lastIndex = first.length - 1

  for (let i = 0; i < count; ++i) {
    const a = first[i]
    const b = second[i]

    if (lastIndex === i && a === b && second.length >= first.length) { return false }
    if (a < b) { return false }
  }

  return true
}

export function isBelowOrEqual (first, second) {
  if (!Array.isArray(first) || !Array.isArray(second)) { return false }

  const count = Math.min(first.length, second.length)
  const lastIndex = first.length - 1

  for (let i = 0; i < count; ++i) {
    const a = first[i]
    const b = second[i]

    if (lastIndex === i && a === b && second.length > first.length) { return false }
    if (a < b) { return false }
  }

  return true
}

export function prevSiblingPath (path) {
  const localIndex = path[path.length - 1]

  if (localIndex === 0) {
    return null
  } else {
    const parentPath = path.slice(0, -1)
    return parentPath.concat([localIndex - 1])
  }
}

export function isArrayEqual (left, right) {
  if (!Array.isArray(left) || !Array.isArray(right)) { return false }

  if (left.length !== right.length) { return false }

  return rightArrayIncludesOrEqualsLeftArray(isArrayEqual, left, right)
}

export function isChildOf (parentPath, path) {
  if (!Array.isArray(parentPath) || !Array.isArray(path)) { return false }

  if (parentPath.length >= path.length) { return false }

  return rightArrayIncludesOrEqualsLeftArray(isChildOf, parentPath, path)
}

export function rightArrayIncludesOrEqualsLeftArray (recurse, left, right) {
  for (let i in left) {
    const leftV = left[i]
    const rightV = right[i]

    if (Array.isArray(leftV) && Array.isArray(rightV)) {
      return recurse(leftV, rightV)
    } else if (leftV !== rightV) {
      return false
    }
  }

  return true
}
