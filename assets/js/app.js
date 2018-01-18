/* global fetch */
// import socket from "./socket"

import raw from 'choo/html/raw'
import html from 'choo/html'
import choo from 'choo'
import devtools from 'choo-devtools'

const app = choo()
app.use(devtools())
app.use(store)
app.route('/app/editor', (state, emit) => {
  deselect(state)
  return mainView(state, emit)
})
app.route('/app/editor/edit/*', (state, emit) => {
  select(state, findByPath(state, state.params.wildcard))
  setTimeout(() => textareaResize(), 10) // HACK
  return mainView(state, emit)
})
app.route('/app/editor/review', (state, emit) => {
  deselect(state)
  return reviewView(state, emit)
})
app.mount('#editor')

function select (state, content) {
  if (content) {
    state.selectedContentPath = content.path
    state.selectedContent = content
  } else {
    state.selectedContentPath = null
    state.selectedContent = null
  }
}
function deselect (state) { select(state, null) }

function url (...paths) {
  return ['/app/editor'].concat(paths).join('/')
}

function getFrontMatter (content) {
  if (content.index) {
    return getFrontMatter(content.index)
  } else {
    return content.front_matter
  }
}

function getTitle (content) {
  const frontMatter = getFrontMatter(content)
  if (frontMatter && frontMatter.title) {
    return frontMatter.title
  } else {
    return '[No title]'
  }
}

function getBody (content) {
  if (content.index) {
    return getBody(content.index)
  } else {
    return content.body || ''
  }
}

function mainView (state, emit) {
  return html`
    <div id="editor">
      <div class="topbar">${editorTopbarView(state, emit)}</div>
      <div class="sidebar">
        ${sectionList(state, state.content.sections, emit)}
      </div>
      ${singleView(state, emit)}
    </div>
  `
}

function editorTopbarView (state, emit) {
  return html`
    <nav>
      <a href="#" onclick=${addClick}>Add new section or page</a>
      <a href=${url('review')}>Review changes</a>
    </nav>
  `

  function addClick (e) {
    e.preventDefault()
    emit('addContent')
  }
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
        <h2>${state.selectedContent.path}</h2>
        <div class="controls">
          ${frontMatterView(state, state.selectedContent, emit)}
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

function frontMatterView (state, content, emit) {
  const frontMatter = getFrontMatter(content)

  if (frontMatter) {
    return html`
      <ul class="frontmatter">
        ${Object.entries(frontMatter).map(([key, value]) => frontMatterItemView(state, key, value, emit))}
      </ul>
    `
  } else {
    return html`
      <ul class="frontmatter">
        ${frontMatterItemView(state, 'title', '', emit)}
      </ul>
    `
  }
}

function frontMatterItemView (state, key, value, emit) {
  return html`
    <li class="frontmatter-field">
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
  let body
  const edits = state.edits[content.path]

  if (edits) {
    body = edits.value
  } else {
    body = getBody(content)
  }

  return html`
    <div class="edit">
      <textarea name="body" oninput=${oninput}>${raw(body)}</textarea>
    </div>
  `

  function oninput (e) {
    emit('contentUpdated', { path: content.path, value: e.target.value })
    textareaResize(e)
  }
}

function reviewView (state, emit) {
  return html`
    <div id="editor">
      <div class="topbar">${reviewTopbarView(state, emit)}</div>
      <div class="sidebar">
        ${sectionList(state, state.content.sections, emit)}
      </div>
      ${editsListView(state, state.edits, emit)}
    </div>
  `
}

function reviewTopbarView (state, emit) {
  return html`
    <nav>
      <a href="#" onclick=${onclick}>Publish all edits</a>
    </nav>
  `

  function onclick (e) {
    e.preventDefault()
    emit('publish')
  }
}

function editsListView (state, edits, emit) {
  return html`
    <div class="edits">
      <h2>Files changed</h2>
      <ul class="edits-list">
        ${Object.entries(edits).map(([path, value]) => editsListItemView(state, path, value, emit))}
      </ul>
    </div>
  `
}

function editsListItemView (state, path, value, emit) {
  return html`
    <li class="edits-item">
      <span class="edits-item-path">Updated ${path}</span>
      <span class="edits-item-value">A diff will appear here in the future...</span>
    </li>
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

  emitter.on('contentUpdated', ({ path, value }) => {
    state.edits[path] = value
  })

  emitter.on('publish', () => {
    emitter.emit('publishing')

    fetch('/app/editor', {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      method: 'POST',
      body: JSON.stringify({ edits: state.edits }),
      credentials: 'include'
    })
    .then(response => response.json())
    .then(json => {
      console.debug({ response: json })
      emitter.emit('published')
    })
    .catch(error => {
      console.error(error)
      emitter.emit('publishFailed')
    })
  })

  emitter.on('published', () => {
    state.edits = {}
    emitter.emit('render')
  })

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
