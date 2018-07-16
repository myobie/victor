import test from 'tape'
import { isItemWithCID } from '../../app/sidebar/helpers'

test('', t => {
  const item = { _cid: 'cid-1' }
  const cid = 'cid-1'

  t.ok(isItemWithCID(item, cid), 'cid did not match')
  t.end()
})
