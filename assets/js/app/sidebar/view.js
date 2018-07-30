import html from 'nanohtml'
import { css } from 'emotion'
import {
  isAbove,
  isAboveOrEqual,
  isArrayEqual,
  isBelow,
  isBelowOrEqual,
  isSameItem
} from './helpers'

export function sidebarView (state, emit) {
  return html`
    <div onclick=${_ => emit('sidebar:deselect')} class=${css`
      height: 100%;
      width: 100%;
      overflow-y: auto;
      overflow-x: hidden;
    `}>
      ${listView([], state.db.children, state, emit)}
    </div>
  `
}

function listView (parents, children, state, emit) {
  return html`
    <div>
      ${olView(parents, children, state, emit)}
    </div>
  `
}

function olView (parents, children, state, emit) {
  return html`
    <ul class="list-reset ${css`
      margin: 0;
      z-index: 3;
      position: relative;
      width: 100%;
    `}">
      ${children.map((item, index) => itemView(parents, item, index, state, emit))}
    </ul>
  `
}

function itemView (parents, item, index, state, emit) {
  const path = parents.concat([index])

  return html`
    <li
      data-cid=${item._cid}
      data-index=${index}
      class=${css`
        box-sizing: border-box;
        position: relative;
        overflow: visible;
      `}>
      <div
        class=${css`
          outline: ${isArrayEqual(state.dragging.over, path) ? '1px solid rgba(255, 0, 0, 0.2)' : ''};
        `}
        ondragover=${dragover}
        ondragenter=${dragenter}
        ondragleave=${dragleave}
        ondrop=${drop}>
        ${titleView(parents, item, path, state, emit)}
      </div>
      ${nestedListView(item, path, state, emit)}
      ${markerView(item, path, state, emit)}
    </li>
  `

  function dragover (e) {
    e.preventDefault() // allow drop

    const rect = e.target.getBoundingClientRect()

    const x = e.clientX - rect.x
    const segments = Math.floor(rect.width / 32) // every 32 pixels
    const ratio = x / rect.width
    const segment = Math.floor(ratio * segments) // which segment is the mouse currently over

    if (state.dragging.overMouseSegment !== segment) {
      emit('sidebar:dragover', segment)
    }
  }

  function dragenter (e) {
    e.preventDefault()

    e.dataTransfer.dropEffect = 'move'
    emit('sidebar:dragenter', path)
  }

  function dragleave (e) {
    e.preventDefault()

    e.dataTransfer.dropEffect = 'none'
    emit('sidebar:dragleave', path)
  }

  function drop (e) {
    e.stopPropagation()
    e.preventDefault()

    const data = e.dataTransfer.getData('application/json')
    emit('sidebar:drop', { path, data })
  }
}

function titleView (parents, item, path, state, emit) {
  const zindex = 999 - parents.length
  const marginLeft = 4 + (parents.length * 32)

  return html`
    <p
      draggable="true"
      ondragstart=${dragstart}
      ondragend=${dragend}
      onclick=${select}
      class=${css`
        margin-top: 4px;
        margin-right: 4px;
        margin-left: ${marginLeft}px;
        margin-bottom: 0;
        padding: 6px 12px;
        position: relative;
        top: ${top(state, path)};
        z-index: ${zindex};
        opacity: ${opacity(state, path)};
        background-color: ${backgroundColor(state, item)};
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      `}>
      ${item.title}
    </p>
  `

  function dragstart (e) {
    e.dataTransfer.effectAllowed = 'move'

    const data = JSON.stringify({ path })
    e.dataTransfer.setData('application/json', data)

    emit('sidebar:dragstart', path)
  }

  function dragend (e) {
    e.preventDefault()

    emit('sidebar:dragend')
  }

  function select (e) {
    e.stopPropagation()
    e.preventDefault()

    if (!state.selectedItem || !isSameItem(state.selectedItem, item)) {
      emit('sidebar:select', { item, path })
    }
  }
}

const markerStyles = css`
  z-index: -1;
  display: block;
  width: 3px;
  background-color: blue;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
  opacity: 0;
  transition: opacity 0.2s ease-in, left 0.03s ease-in;
`

function markerView (item, path, state, emit) {
  if (state.isOver && isArrayEqual(state.dragging.over, path)) {
    return html`
      <span class="${markerStyles} ${css`
        left: ${left(state, path)}px;
      `}">
      </span>
    `
  } else {
    return ''
  }
}

function nestedListView (item, path, state, emit, options = {}) {
  // if this item doesn't have children, then do nothing
  if (!Array.isArray(item.children)) { return '' }
  // if this is the currently dragged item, then don't render it's children
  if (isArrayEqual(state.dragging.from, path)) { return '' }

  return html`
    <div class=${css`
      position: relative;
      overflow: visible;
    `}>
      ${listView(path, item.children, state, emit)}
    </div>
  `
}

function opacity (state, path) {
  if (!state.isDragging) { return '1' }

  // show everyone except for the one being dragged
  if (isArrayEqual(state.dragging.from, path)) {
    return '0'
  } else {
    return '1'
  }
}

function backgroundColor (state, item) {
  if (state.selectedItem && state.selectedItem._cid === item._cid) {
    return 'yellow'
  } else {
    return 'rgba(255, 255, 255, 0.1)'
  }
}

function top (state, path) {
  if (!state.isDragging) { return '0' }

  const from = state.dragging.from
  const over = state.dragging.over

  if (isArrayEqual(from, over)) { return '0' }

  if (isAbove(from, path) && isBelowOrEqual(over, path)) {
    // came from above and I am between where it was and where it wants to go
    return '-34px'
  } else if (isBelow(from, path) && isAboveOrEqual(over, path)) {
    // came from below and I am between where it was and where it wants to go
    return '34px'
  } else {
    return '0'
  }
}

function left (state, path) {
  const left = state.dragging.overSegment || 0
  return (left * 32) + 3 // 32 is our indent amount and we nudge it a bit to make it more visible
}
