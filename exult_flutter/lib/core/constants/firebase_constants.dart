/// Firebase collection and field names
class FirebaseConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String loansCollection = 'loans';
  static const String subscriptionsCollection = 'subscriptions';
  static const String contactsCollection = 'contacts';
  static const String mailCollection = 'mail';

  // Storage paths
  static const String bookCoversPath = 'book_covers';
  static const String profilePicturesPath = 'profile_pictures';

  // User fields
  static const String userUid = 'uid';
  static const String userEmail = 'email';
  static const String userDisplayName = 'displayName';
  static const String userPhoneNumber = 'phoneNumber';
  static const String userRole = 'role';
  static const String userAddress = 'address';
  static const String userCreatedAt = 'createdAt';
  static const String userIsActive = 'isActive';

  // Book fields
  static const String bookId = 'id';
  static const String bookTitle = 'title';
  static const String bookAuthor = 'author';
  static const String bookIsbn = 'isbn';
  static const String bookDescription = 'description';
  static const String bookCoverImageUrl = 'coverImageUrl';
  static const String bookOwnerType = 'ownerType';
  static const String bookCategory = 'category';
  static const String bookDepositAmount = 'depositAmount';
  static const String bookStatus = 'status';
  static const String bookCreatedAt = 'createdAt';

  // Loan fields
  static const String loanId = 'id';
  static const String loanBookId = 'bookId';
  static const String loanBorrowerId = 'borrowerId';
  static const String loanSubscriptionId = 'subscriptionId';
  static const String loanStatus = 'status';
  static const String loanDepositAmount = 'depositAmount';
  static const String loanDepositPaid = 'depositPaid';
  static const String loanBorrowedAt = 'borrowedAt';
  static const String loanDueDate = 'dueDate';
  static const String loanReturnedAt = 'returnedAt';

  // Subscription fields
  static const String subscriptionId = 'id';
  static const String subscriptionUserId = 'userId';
  static const String subscriptionTier = 'tier';
  static const String subscriptionStatus = 'status';
  static const String subscriptionBillingCycle = 'billingCycle';
  static const String subscriptionMonthlyAmount = 'monthlyAmount';
  static const String subscriptionMaxBooks = 'maxBooks';
  static const String subscriptionCurrentBooksCount = 'currentBooksCount';
  static const String subscriptionStartDate = 'startDate';
  static const String subscriptionEndDate = 'endDate';

  // Contact fields
  static const String contactId = 'id';
  static const String contactName = 'name';
  static const String contactEmail = 'email';
  static const String contactMessage = 'message';
  static const String contactCreatedAt = 'createdAt';
  static const String contactReplied = 'replied';
}
