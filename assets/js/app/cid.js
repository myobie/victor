let _currentCID = 0

export function nextCID () {
  _currentCID += 1
  return `cid-${_currentCID}`
}

export function assignCID (item) {
  if (item._cid === undefined) {
    item._cid = nextCID()
  }

  if (Array.isArray(item.children)) {
    assignCIDs(item.children)
  }

  if (Array.isArray(item.sections)) {
    assignCIDs(item.sections)
  }

  if (Array.isArray(item.pages)) {
    assignCIDs(item.pages)
  }

  if (Array.isArray(item.resources)) {
    assignCIDs(item.resources)
  }

  if (Array.isArray(item.invalid)) {
    assignCIDs(item.invalid)
  }

  return item
}

export function assignCIDs (items) {
  if (!Array.isArray(items)) { return }
  for (let item of items) { assignCID(item) }
  return items
}
