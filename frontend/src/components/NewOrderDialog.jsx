import { useState } from 'react'

const EMPTY_FORM = { customer_name: '', product: '', amount: '' }

export const NewOrderDialog = ({ isOpen, onClose, onSubmit }) => {
  const [form, setForm] = useState(EMPTY_FORM)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState(null)

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm((prev) => ({ ...prev, [name]: value }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setIsSubmitting(true)
    setError(null)

    try {
      await onSubmit({
        customer_name: form.customer_name,
        product: form.product,
        amount_cents: Math.round(parseFloat(form.amount) * 100),
      })
      setForm(EMPTY_FORM)
      onClose()
    } catch (err) {
      setError(err.message)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) onClose()
  }

  if (!isOpen) return null

  return (
    <div className="dialog-overlay" onClick={handleOverlayClick}>
      <div className="dialog">
        <div className="dialog__header">
          <h2>New Order</h2>
          <button className="dialog__close" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        <form className="dialog__form" onSubmit={handleSubmit}>
          <label>
            Customer Name
            <input
              name="customer_name"
              type="text"
              value={form.customer_name}
              onChange={handleChange}
              required
              autoFocus
            />
          </label>

          <label>
            Product
            <input
              name="product"
              type="text"
              value={form.product}
              onChange={handleChange}
              required
            />
          </label>

          <label>
            Amount (USD)
            <input
              name="amount"
              type="number"
              min="0.01"
              step="0.01"
              value={form.amount}
              onChange={handleChange}
              required
            />
          </label>

          {error && <p className="dialog__error">{error}</p>}

          <div className="dialog__actions">
            <button type="button" onClick={onClose} disabled={isSubmitting}>
              Cancel
            </button>
            <button type="submit" className="btn--primary" disabled={isSubmitting}>
              {isSubmitting ? 'Creating…' : 'Create Order'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
