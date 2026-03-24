import { render, screen } from '@testing-library/react'
import { Dashboard } from '../../pages/Dashboard'
import { useOrders } from '../../hooks/useOrders'

vi.mock('../../hooks/useOrders')

const mockOrders = [
  { id: 1, customer_name: 'Alice', product: 'Widget', amount_cents: 5000, status: 'pending' },
  { id: 2, customer_name: 'Bob', product: 'Gadget', amount_cents: 3000, status: 'completed' },
  { id: 3, customer_name: 'Carol', product: 'Doohickey', amount_cents: 2000, status: 'pending' },
]

beforeEach(() => {
  useOrders.mockReturnValue({
    orders: mockOrders,
    isLoading: false,
    error: null,
    createOrder: vi.fn(),
  })
})

afterEach(() => {
  vi.restoreAllMocks()
})

describe('Dashboard', () => {
  describe('stats', () => {
    it('shows total order count', () => {
      render(<Dashboard />)
      expect(screen.getByText('Total Orders')).toBeInTheDocument()
      expect(screen.getByText('3')).toBeInTheDocument()
    })

    it('shows pending order count', () => {
      render(<Dashboard />)
      expect(screen.getByText('Pending Orders')).toBeInTheDocument()
      expect(screen.getByText('2')).toBeInTheDocument()
    })

    it('shows total revenue formatted as currency', () => {
      render(<Dashboard />)
      expect(screen.getByText('Total Revenue')).toBeInTheDocument()
      expect(screen.getByText('$100.00')).toBeInTheDocument()
    })
  })

  it('shows loading state', () => {
    useOrders.mockReturnValue({ orders: [], isLoading: true, error: null, createOrder: vi.fn() })
    render(<Dashboard />)
    expect(screen.getByText(/loading/i)).toBeInTheDocument()
  })

  it('shows error banner when fetch fails', () => {
    useOrders.mockReturnValue({ orders: [], isLoading: false, error: 'Failed to fetch orders', createOrder: vi.fn() })
    render(<Dashboard />)
    expect(screen.getByText('Failed to fetch orders')).toBeInTheDocument()
  })
})
