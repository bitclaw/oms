import { render, screen } from '@testing-library/react'
import { OrderTable } from '../../components/OrderTable'

const orders = [
  {
    id: 1,
    customer_name: 'Daniel Chavez',
    product: 'Product 1',
    amount_cents: 4999,
    status: 'pending',
    created_at: '2026-03-23T00:00:00.000Z',
  },
  {
    id: 2,
    customer_name: 'Alice Smith',
    product: 'Widget Pro',
    amount_cents: 9900,
    status: 'completed',
    created_at: '2026-03-22T00:00:00.000Z',
  },
]

describe('OrderTable', () => {
  it('renders the empty state when there are no orders', () => {
    render(<OrderTable orders={[]} />)
    expect(screen.getByText(/no orders yet/i)).toBeInTheDocument()
  })

  it('renders a row for each order', () => {
    render(<OrderTable orders={orders} />)
    expect(screen.getByText('Daniel Chavez')).toBeInTheDocument()
    expect(screen.getByText('Alice Smith')).toBeInTheDocument()
  })

  it('formats amount_cents as dollars', () => {
    render(<OrderTable orders={orders} />)
    expect(screen.getByText('$49.99')).toBeInTheDocument()
    expect(screen.getByText('$99.00')).toBeInTheDocument()
  })

  it('renders the status badge for each order', () => {
    render(<OrderTable orders={orders} />)
    expect(screen.getByText('pending')).toBeInTheDocument()
    expect(screen.getByText('completed')).toBeInTheDocument()
  })
})
