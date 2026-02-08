# Exult - Data Models Reference

## UserModel (`domain/models/user_model.dart`)
```
Fields:
  uid: String              # Firebase UID (doc ID)
  email: String
  displayName: String
  phoneNumber: String?
  role: UserRole           # subscriber | admin
  address: UserAddress?    # street, city, pincode
  createdAt: DateTime
  isActive: bool

Computed:
  isAdmin → role == UserRole.admin
```

## Book (`domain/models/book_model.dart`)
```
Fields:
  id: String               # Firestore doc ID
  title: String
  author: String
  isbn: String?
  description: String
  coverImageUrl: String?
  ownerType: BookOwnerType # business | user
  categories: List<String> # ECORFAN categories
  depositAmount: double    # INR
  status: BookStatus       # available | borrowed
  totalCopies: int
  availableCopies: int
  createdAt: DateTime

Computed:
  isAvailable → status == BookStatus.available
```

## Loan (`domain/models/loan_model.dart`)
```
Fields:
  id: String
  bookId: String           # FK → books/
  borrowerId: String       # FK → users/
  subscriptionId: String   # FK → subscriptions/
  status: LoanStatus       # active | returned | overdue
  depositAmount: double
  depositPaid: bool
  borrowedAt: DateTime
  dueDate: DateTime        # borrowedAt + 14 days
  returnedAt: DateTime?

Computed:
  isActive → status == active && !isOverdue
  isOverdue → status != returned && dueDate < now
  daysRemaining → (dueDate - now).inDays
  daysOverdue → (now - dueDate).inDays
```

## Subscription (`domain/models/subscription_model.dart`)
```
Fields:
  id: String
  userId: String           # FK → users/
  tier: SubscriptionTier   # oneBook | threeBooks | fiveBooks
  status: SubscriptionStatus # active | cancelled | expired
  billingCycle: BillingCycle # monthly | annual
  monthlyAmount: double    # INR
  maxBooks: int            # Tier limit
  currentBooksCount: int   # Currently borrowed
  startDate: DateTime
  endDate: DateTime

Computed:
  isActive → status == active && endDate > now
  canBorrowMore → currentBooksCount < maxBooks
  remainingBooks → maxBooks - currentBooksCount
  isExpired → endDate < now
```

## Contact (`domain/models/contact_model.dart`)
```
Fields:
  id: String
  name: String
  email: String
  message: String
  createdAt: DateTime
  replied: bool
```

## Enums
```
UserRole: subscriber, admin
BookStatus: available, borrowed
BookOwnerType: business, user
LoanStatus: active, returned, overdue
SubscriptionTier: oneBook, threeBooks, fiveBooks
SubscriptionStatus: active, cancelled, expired
BillingCycle: monthly, annual
```
