import { useState, useEffect } from 'react'

const API_URL = import.meta.env.VITE_API_URL

export const useOrders = () => {
  const [orders, setOrders] = useState([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState(null)

  const fetchOrders = async () => {
    setIsLoading(true)
    setError(null)

    try {
      const response = await fetch(`${API_URL}/api/v1/orders`)
      if (!response.ok) throw new Error('Failed to fetch orders')
      const data = await response.json()
      setOrders(data)
    } catch (err) {
      setError(err.message)
    } finally {
      setIsLoading(false)
    }
  }

  const createOrder = async (payload) => {
    const response = await fetch(`${API_URL}/api/v1/orders`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ order: payload }),
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.errors?.join(', ') || 'Failed to create order')
    }

    await fetchOrders()
  }

  useEffect(() => {
    fetchOrders()
  }, [])  

  return { orders, isLoading, error, fetchOrders, createOrder }
}
