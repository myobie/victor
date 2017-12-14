// import socket from "./socket"

import raw from 'choo/html/raw'
import html from 'choo/html'
import choo from 'choo'
import devtools from 'choo-devtools'

const app = choo()
app.use(devtools())
app.use(store)
app.route('/app/editor', (state, emit) => {
  state.selectedContentPath = null
  state.selectedContent = null
  return mainView(state, emit)
})
app.route('/app/editor/edit/*', (state, emit) => {
  const selectedContent = findByPath(state, state.params.wildcard)
  if (selectedContent) {
    state.selectedContentPath = selectedContent.path
    if (selectedContent.index) {
      state.selectedContent = selectedContent.index
    } else {
      state.selectedContent = selectedContent
    }
  }
  setTimeout(() => textareaResize(), 10)
  return mainView(state, emit)
})
app.mount('#editor')

function url (...paths) {
  return ['/app/editor'].concat(paths).join('/')
}

function getTitle (content) {
  if (content.index) {
    return getTitle(content.index)
  } else {
    if (content.top_matter && content.top_matter.title) {
      return content.top_matter.title
    } else {
      return '[No title]'
    }
  }
}

function mainView (state, emit) {
  return html`
    <div id="editor">
      <div class="topbar"></div>
      <div class="sidebar">
        ${sectionList(state, state.content.sections, emit)}
      </div>
      ${singleView(state, emit)}
    </div>
  `
}

function sectionList (state, sections, emit) {
  if (sections.length === 0) {
    return ''
  } else {
    return html`
      <ul class="sections">
        ${sections.map(section => sectionListItem(state, section, emit))}
      </ul>
    `
  }
}

function sectionListItem (state, section, emit) {
  let classes = 'section'
  if (state.selectedContentPath === section.path) {
    classes += ' selected'
  }
  return html`
    <li class=${classes}>
      <a href="${url('edit', section.path)}">
        <span class="section-title">${getTitle(section)}</span>
        <span class="section-id">${section.id}</span>
      </a>
      ${sectionList(state, section.subsections, emit)}
      ${pageList(state, section.pages, emit)}
    </li>
  `
}

function pageList (state, pages, emit) {
  return html`
    <ul class="pages">
      ${pages.map(page => pageListItem(state, page, emit))}
    </ul>
  `
}

function pageListItem (state, page, emit) {
  let classes = 'page'
  if (state.selectedContentPath === page.path) {
    classes += ' selected'
  }
  return html`
    <li class=${classes}>
      <a href="${url('edit', page.path)}">
        <span class="page-title">${getTitle(page)}</span>
        <span class="page-id">${page.id}</span>
      </a>
    </li>
  `
}

function singleView (state, emit) {
  if (state.selectedContent) {
    return html`
      <div class="single">
        <div class="controls">
          ${topMatterView(state, state.selectedContent, emit)}
          ${editView(state, state.selectedContent, emit)}
        </div>
      </div>
    `
  } else {
    return html`
      <div class="single"></div>
    `
  }
}

function topMatterView (state, content, emit) {
  return html`
    <ul class="topmatter">
      ${Object.entries(content.top_matter).map(([key, value]) => topMatterItemView(state, key, value, emit))}
    </ul>
  `
}

function topMatterItemView (state, key, value, emit) {
  return html`
    <li class="topmatter-field">
      <label>
        ${key}:
        <input name=${key} value=${value} />
      </label>
    </li>
  `
}

function textareaResize (e) {
  if (e && e.target) {
    e.target.style.height = '1px'
    const newHeight = 25 + e.target.scrollHeight
    e.target.style.height = `${newHeight}px`
  } else {
    const el = document.querySelector('.single .edit textarea')
    if (el) {
      textareaResize({ target: el })
    }
  }
}

function editView (state, content, emit) {
  return html`
    <div class="edit">
      <textarea name="body" oninput=${textareaResize}>${raw(content.body)}</textarea>
    </div>
  `
}

function store (state, emitter) {
  state.content = {
    sections: [],
    byPath: {}
  }
  // Edits are stored by the path index of the edited content
  state.edits = {}
  state.selectedContentPath = null

  if (window.bootstrapContent && window.bootstrapContent.sections) {
    state.content.sections = window.bootstrapContent.sections
    state.content.byPath = indexByPath(state.content.sections)
  }
}

function findByPath (state, path) {
  return state.content.byPath[path]
}

// Mutates!
function indexByPath (sections) {
  let pathMap = {}

  for (let section of sections) {
    processSectionForPathIndex(section, '', pathMap)
  }

  return pathMap
}

function processSectionForPathIndex (section, currentPath, pathMap) {
  let path
  if (currentPath === '') {
    path = section.id
  } else {
    path = `${currentPath}/${section.id}`
  }
  const sectionPath = `${path}/_index.md`
  section.path = sectionPath
  pathMap[sectionPath] = section

  for (let subsection of section.subsections) {
    processSectionForPathIndex(subsection, path, pathMap)
  }

  for (let page of section.pages) {
    processPageForPathIndex(page, path, pathMap)
  }
}

function processPageForPathIndex (page, currentPath, pathMap) {
  const path = `${currentPath}/${page.id}`
  page.path = path
  pathMap[path] = page
}
