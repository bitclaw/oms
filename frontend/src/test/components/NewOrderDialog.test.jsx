import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { NewOrderDialog } from '../../components/NewOrderDialog'

const noop = () => {}

describe('NewOrderDialog', () => {
  it('renders nothing when closed', () => {
    render(<NewOrderDialog isOpen={false} onClose={noop} onSubmit={noop} />)
    expect(screen.queryByText('New Order')).not.toBeInTheDocument()
  })

  it('renders the form when open', () => {
    render(<NewOrderDialog isOpen={true} onClose={noop} onSubmit={noop} />)
    expect(screen.getByText('New Order')).toBeInTheDocument()
    expect(screen.getByLabelText('Customer Name')).toBeInTheDocument()
    expect(screen.getByLabelText('Product')).toBeInTheDocument()
    expect(screen.getByLabelText('Amount (USD)')).toBeInTheDocument()
  })

  it('calls onSubmit with cents-converted payload', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn().mockResolvedValue()

    render(<NewOrderDialog isOpen={true} onClose={noop} onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText('Customer Name'), 'Daniel Chavez')
    await user.type(screen.getByLabelText('Product'), 'Product 1')
    await user.type(screen.getByLabelText('Amount (USD)'), '49.99')
    await user.click(screen.getByRole('button', { name: /create order/i }))

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        customer_name: 'Daniel Chavez',
        product: 'Product 1',
        amount_cents: 4999,
      })
    })
  })

  it('displays an error message when onSubmit rejects', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn().mockRejectedValue(new Error('Something went wrong'))

    render(<NewOrderDialog isOpen={true} onClose={noop} onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText('Customer Name'), 'Daniel Chavez')
    await user.type(screen.getByLabelText('Product'), 'Product 1')
    await user.type(screen.getByLabelText('Amount (USD)'), '49.99')
    await user.click(screen.getByRole('button', { name: /create order/i }))

    await waitFor(() => {
      expect(screen.getByText('Something went wrong')).toBeInTheDocument()
    })
  })

  it('calls onClose when cancel is clicked', async () => {
    const user = userEvent.setup()
    const onClose = vi.fn()

    render(<NewOrderDialog isOpen={true} onClose={onClose} onSubmit={noop} />)
    await user.click(screen.getByRole('button', { name: /cancel/i }))

    expect(onClose).toHaveBeenCalled()
  })
})
