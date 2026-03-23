const formatAmount = (cents) => {
  return (cents / 100).toLocaleString('en-US', {
    style: 'currency',
    currency: 'USD',
  })
}

const formatDate = (iso) => {
  return new Date(iso).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}

export const OrderTable = ({ orders }) => {
  if (orders.length === 0) {
    return <p className="empty-state">No orders yet. Create one to get started.</p>
  }

  return (
    <table className="order-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Customer</th>
          <th>Product</th>
          <th>Amount</th>
          <th>Status</th>
          <th>Date</th>
        </tr>
      </thead>
      <tbody>
        {orders.map((order) => (
          <tr key={order.id}>
            <td>#{order.id}</td>
            <td>{order.customer_name}</td>
            <td>{order.product}</td>
            <td>{formatAmount(order.amount_cents)}</td>
            <td>
              <span className={`status-badge status-badge--${order.status}`}>
                {order.status}
              </span>
            </td>
            <td>{formatDate(order.created_at)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
