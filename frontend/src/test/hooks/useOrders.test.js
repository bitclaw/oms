import { renderHook, waitFor } from '@testing-library/react'
import { useOrders } from '../../hooks/useOrders'

const mockOrders = [
  { id: 1, customer_name: 'Daniel Chavez', product: 'Product 1', amount_cents: 4999, status: 'pending' },
]

beforeEach(() => {
  global.fetch = vi.fn()
})

afterEach(() => {
  vi.restoreAllMocks()
})

describe('useOrders', () => {
  describe('fetchOrders', () => {
    it('populates orders on success', async () => {
      global.fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockOrders,
      })

      const { result } = renderHook(() => useOrders())

      await waitFor(() => expect(result.current.isLoading).toBe(false))

      expect(result.current.orders).toEqual(mockOrders)
      expect(result.current.error).toBeNull()
    })

    it('sets error on failure', async () => {
      global.fetch.mockResolvedValueOnce({ ok: false })

      const { result } = renderHook(() => useOrders())

      await waitFor(() => expect(result.current.isLoading).toBe(false))

      expect(result.current.error).toBe('Failed to fetch orders')
      expect(result.current.orders).toEqual([])
    })
  })

  describe('createOrder', () => {
    it('posts the order and refreshes the list', async () => {
      const newOrder = { customer_name: 'Alice', product: 'Widget', amount_cents: 1000 }

      global.fetch
        .mockResolvedValueOnce({ ok: true, json: async () => mockOrders })  // initial fetch
        .mockResolvedValueOnce({ ok: true, json: async () => newOrder })     // create
        .mockResolvedValueOnce({ ok: true, json: async () => [...mockOrders, newOrder] }) // refresh

      const { result } = renderHook(() => useOrders())
      await waitFor(() => expect(result.current.isLoading).toBe(false))

      await result.current.createOrder(newOrder)

      await waitFor(() => expect(result.current.orders).toHaveLength(2))
      expect(global.fetch).toHaveBeenCalledTimes(3)
    })

    it('throws when the API returns an error', async () => {
      global.fetch
        .mockResolvedValueOnce({ ok: true, json: async () => [] })
        .mockResolvedValueOnce({
          ok: false,
          json: async () => ({ errors: ['Amount must be greater than 0'] }),
        })

      const { result } = renderHook(() => useOrders())
      await waitFor(() => expect(result.current.isLoading).toBe(false))

      await expect(result.current.createOrder({})).rejects.toThrow(
        'Amount must be greater than 0'
      )
    })
  })
})
