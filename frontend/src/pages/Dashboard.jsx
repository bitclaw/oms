import { useState } from 'react'

import { NewOrderDialog } from '../components/NewOrderDialog'
import { OrderTable } from '../components/OrderTable'
import { StatCard } from '../components/StatCard'
import { useOrders } from '../hooks/useOrders'

const totalRevenue = (orders) => {
  const cents = orders.reduce((sum, o) => sum + o.amount_cents, 0)
  return (cents / 100).toLocaleString('en-US', { style: 'currency', currency: 'USD' })
}

const pendingCount = (orders) => orders.filter((o) => o.status === 'pending').length

export const Dashboard = () => {
  const { orders, isLoading, error, createOrder } = useOrders()
  const [isDialogOpen, setIsDialogOpen] = useState(false)

  const handleOpenDialog = () => setIsDialogOpen(true)
  const handleCloseDialog = () => setIsDialogOpen(false)

  return (
    <div className="dashboard">
      <header className="dashboard__header">
        <h1>Order Management</h1>
        <button className="btn--primary" onClick={handleOpenDialog}>
          + New Order
        </button>
      </header>

      <div className="stat-cards">
        <StatCard label="Total Orders" value={orders.length} />
        <StatCard label="Pending Orders" value={pendingCount(orders)} />
        <StatCard label="Total Revenue" value={totalRevenue(orders)} />
      </div>

      {error && <p className="error-banner">{error}</p>}

      {isLoading
        ? <p className="loading">Loading orders…</p>
        : <OrderTable orders={orders} />
      }

      <NewOrderDialog
        isOpen={isDialogOpen}
        onClose={handleCloseDialog}
        onSubmit={createOrder}
      />
    </div>
  )
}
