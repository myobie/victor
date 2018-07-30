import test from 'tape'
import {
  isAbove,
  isAboveOrEqual,
  isBelow,
  isBelowOrEqual,
  isItemWithCID
} from '../../app/sidebar/helpers'

test('isItemWithCID compares _cid to argument', t => {
  const item = { _cid: 'cid-1' }
  const cid = 'cid-1'

  t.ok(isItemWithCID(item, cid), 'cid did not match')
  t.end()
})

test('isAbove only works with index paths', t => {
  t.notOk(isAbove('0', [1]), 'string first argument is always false')
  t.notOk(isAbove([1], '0'), 'string second argument is always false')

  t.end()
})

test('isAbove tests index paths to see if left is less than right', t => {
  t.ok(isAbove([0], [1]), '0 is above 1')
  t.notOk(isAbove([2], [1]), '2 is not above 1')

  t.notOk(isAbove([1], [1]), '1 is not above 1')
  t.notOk(isAbove([1, 2, 3], [1, 2, 3]), '1, 2, 3 is not above 1, 2, 3')

  t.ok(isAbove([1], [1, 2]), '1 is above 1, 2')
  t.ok(isAbove([1, 1, 1], [1, 2]), '1, 1, 1 is above 1, 2')

  t.notOk(isAbove([2], [1, 2]), '2 is not above 1, 2')
  t.notOk(isAbove([1, 2, 1], [1, 2]), '1, 2, 1 is not above 1, 2')

  t.ok(isAbove([1, 2], [1, 2, 1]), '1, 2 is above 1, 2, 1')

  t.ok(isAbove([1, 1], [1, 2]), '1, 1 is above 1, 2')
  t.notOk(isAbove([1, 3], [1, 2]), '1, 3 is not above 1, 2')
  t.notOk(isAbove([1, 3, 1], [1, 2]), '1, 3, 1 is not above 1, 2')

  t.ok(isAbove([0, 1], [0, 3, 3]), '0, 1 is above 0, 3, 3')
  t.ok(isAbove([0, 1, 0], [2, 10]), '0, 1, 0 is above 2, 10')
  t.ok(isAbove([0], [2, 0, 2]), '0 is above 2, 0, 2')

  t.ok(isAbove([0, 2, 2], [0, 3, 2]), '0, 2, 2 is above 0, 3, 2')
  t.ok(isAbove([0, 2, 3], [0, 3, 2]), '0, 2, 3 is above 0, 3, 2')

  t.end()
})

test('isAboveOrEqual only works with index paths', t => {
  t.notOk(isAboveOrEqual('0', [1]), 'string first argument is always false')
  t.notOk(isAboveOrEqual([1], '0'), 'string second argument is always false')

  t.end()
})

test('isAboveOrEqual tests index paths to see if left is less than or equal right', t => {
  t.ok(isAboveOrEqual([0], [1]), '0 is above 1')
  t.notOk(isAboveOrEqual([2], [1]), '2 is not above 1')

  t.ok(isAboveOrEqual([1], [1]), '1 is equal to 1')
  t.ok(isAboveOrEqual([1, 2, 3], [1, 2, 3]), '1, 2, 3 is equal 1, 2, 3')

  t.ok(isAboveOrEqual([1], [1, 2]), '1 is above 1, 2')
  t.ok(isAboveOrEqual([1, 1, 1], [1, 2]), '1, 1, 1 is above 1, 2')

  t.notOk(isAboveOrEqual([2], [1, 2]), '2 is not above 1, 2')
  t.notOk(isAboveOrEqual([1, 2, 1], [1, 2]), '1, 2, 1 is not above 1, 2')

  t.ok(isAboveOrEqual([1, 2], [1, 2, 1]), '1, 2 is above 1, 2, 1')

  t.ok(isAboveOrEqual([1, 1], [1, 2]), '1, 1 is above 1, 2')
  t.notOk(isAboveOrEqual([1, 3], [1, 2]), '1, 3 is not above 1, 2')
  t.notOk(isAboveOrEqual([1, 3, 1], [1, 2]), '1, 3, 1 is not above 1, 2')

  t.ok(isAboveOrEqual([0, 1], [0, 3, 3]), '0, 1 is above 0, 3, 3')
  t.ok(isAboveOrEqual([0, 1, 0], [2, 10]), '0, 1, 0 is above 2, 10')
  t.ok(isAboveOrEqual([0], [2, 0, 2]), '0 is above 2, 0, 2')

  t.end()
})

test('isBelow only works with index paths', t => {
  t.notOk(isBelow('0', [1]), 'string first argument is always false')
  t.notOk(isBelow([1], '0'), 'string second argument is always false')

  t.end()
})

test('isBelow tests index paths to see if left is less than right', t => {
  t.ok(isBelow([1], [0]), '1 is below 0')
  t.notOk(isBelow([1], [2]), '1 is not below 2')

  t.notOk(isBelow([1], [1]), '1 is not below 1')
  t.notOk(isBelow([1, 2, 3], [1, 2, 3]), '1, 2, 3 is not below 1, 2, 3')

  t.ok(isBelow([1, 2], [1]), '1, 2 is below 1')
  t.ok(isBelow([1, 2], [1, 1, 1]), '1, 2 is below 1, 1, 1')

  t.notOk(isBelow([1, 2], [2]), '1, 2 is not below 2')
  t.notOk(isBelow([1, 2], [1, 2, 1]), '1, 2 is not below 1, 2, 1')

  t.ok(isBelow([1, 2, 1], [1, 2]), '1, 2, 1 is below 1, 2')

  t.ok(isBelow([1, 2], [1, 1]), '1, 2 is below 1, 1')
  t.notOk(isBelow([1, 2], [1, 3]), '1, 2 is not below 1, 3')
  t.notOk(isBelow([1, 2], [1, 3, 1]), '1, 2 is not below 1, 3, 1')

  t.notOk(isBelow([0, 1], [0, 3, 3]), '0, 1 is not below 0, 3, 3')
  t.notOk(isBelow([0, 1], [0, 3, 3]), '0, 1 is not below 0, 3, 3')
  t.notOk(isBelow([0, 1, 0], [2, 10]), '0, 1, 0 is not below 2, 10')
  t.notOk(isBelow([0], [2, 0, 2]), '0 is not below 2, 0, 2')

  t.ok(isBelow([0, 3, 2], [0, 2, 2]), '0, 3, 2 is below 0, 2, 2')
  t.ok(isBelow([0, 3, 2], [0, 2, 3]), '0, 3, 2 is below 0, 2, 3')

  t.end()
})

test('isBelowOrEqual only works with index paths', t => {
  t.notOk(isBelowOrEqual('0', [1]), 'string first argument is always false')
  t.notOk(isBelowOrEqual([1], '0'), 'string second argument is always false')

  t.end()
})

test('isBelowOrEqual tests index paths to see if left is less than or equal right', t => {
  t.ok(isBelowOrEqual([1], [0]), '1 is below 0')
  t.notOk(isBelowOrEqual([1], [2]), '1 is not below 2')

  t.ok(isBelowOrEqual([1], [1]), '1 is equal to 1')
  t.ok(isBelowOrEqual([1, 2, 3], [1, 2, 3]), '1, 2, 3 is equal to 1, 2, 3')

  t.ok(isBelowOrEqual([1, 2], [1]), '1, 2 is below 1')
  t.ok(isBelowOrEqual([1, 2], [1, 1, 1]), '1, 2 is below 1, 1, 1')

  t.notOk(isBelowOrEqual([1, 2], [2]), '1, 2 is not below 2')
  t.notOk(isBelowOrEqual([1, 2], [1, 2, 1]), '1, 2 is not below 1, 2, 1')

  t.ok(isBelowOrEqual([1, 2, 1], [1, 2]), '1, 2, 1 is below 1, 2')

  t.ok(isBelowOrEqual([1, 2], [1, 1]), '1, 2 is below 1, 1')
  t.notOk(isBelowOrEqual([1, 2], [1, 3]), '1, 2 is not below 1, 3')
  t.notOk(isBelowOrEqual([1, 2], [1, 3, 1]), '1, 2 is not below 1, 3, 1')

  t.notOk(isBelowOrEqual([0, 1], [0, 3, 3]), '0, 1 is not below 0, 3, 3')
  t.notOk(isBelowOrEqual([0, 1, 0], [2, 10]), '0, 1, 0 is not below 2, 10')
  t.notOk(isBelowOrEqual([0], [2, 0, 2]), '0 is not below 2, 0, 2')

  t.end()
})
