import { render, screen } from '@testing-library/react'
import { StatCard } from '../../components/StatCard'

describe('StatCard', () => {
  it('renders the label', () => {
    render(<StatCard label="Total Orders" value={5} />)
    expect(screen.getByText('Total Orders')).toBeInTheDocument()
  })

  it('renders the value', () => {
    render(<StatCard label="Total Orders" value={42} />)
    expect(screen.getByText(42)).toBeInTheDocument()
  })
})
