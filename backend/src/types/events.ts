export type OrderCreatedEvent = {
  type: 'ORDER_CREATED';
  orderId: string;
  clientId: string;
  artistId: string;
  commissionSlotId: string;
  description: string;
  referenceImage: string;
  createdAt: Date;
};

export type OrderAcceptedEvent = {
  type: 'ORDER_ACCEPTED';
  orderId: string;
  clientId: string;
  artistId: string;
  acceptedAt: Date;
};

export type OrderRejectedEvent = {
  type: 'ORDER_REJECTED';
  orderId: string;
  clientId: string;
  artistId: string;
  rejectedAt: Date;
};

export type OrderStatusChangedEvent = {
  type: 'ORDER_STATUS_CHANGED';
  orderId: string;
  clientId: string;
  artistId: string;
  status: string;
  changedAt: Date;
};

export type CommissionOrderQueuedEvent = {
  type: 'COMMISSION_ORDER_QUEUED';
  orderId: string;
  commissionSlotId: string;
  clientId: string;
  artistId: string;
  queuePosition: number;
  totalOrders: number;
  createdAt: Date;
};

export type OrderEvent = 
  | OrderCreatedEvent 
  | OrderAcceptedEvent 
  | OrderRejectedEvent 
  | OrderStatusChangedEvent;

export type CommissionEvent = CommissionOrderQueuedEvent;
