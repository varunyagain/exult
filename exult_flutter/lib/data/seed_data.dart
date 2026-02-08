import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exult_flutter/core/constants/firebase_constants.dart';

/// Seeds sample book data into Firestore
/// Call this once to populate the database with test data
class SeedData {
  static Future<void> seedBooks() async {
    final firestore = FirebaseFirestore.instance;
    final booksCollection = firestore.collection(FirebaseConstants.booksCollection);

    // Check if books already exist
    final existing = await booksCollection.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('Books already exist in database. Skipping seed.');
      return;
    }

    final sampleBooks = [
      // Literature - 3 books
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'isbn': '978-0061120084',
        'description': 'A classic of modern American literature, this novel explores themes of racial injustice and moral growth in the Deep South during the 1930s. Through the eyes of young Scout Finch, we witness her father Atticus defend a Black man falsely accused of a crime, teaching timeless lessons about courage and compassion.',
        'coverImageUrl': 'https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg',
        'ownerType': 'business',
        'categories': ['Literature & Rhetoric', 'English Novel'],
        'genres': ['Fiction', 'Classic & Literary Fiction'],
        'depositAmount': 200,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'isbn': '978-0451524935',
        'description': 'A dystopian masterpiece that depicts a totalitarian society where independent thinking is a crime and Big Brother watches everyone. Winston Smith struggles against the Party\'s oppressive regime in this chilling warning about the dangers of absolute power.',
        'coverImageUrl': 'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',
        'ownerType': 'business',
        'categories': ['Literature & Rhetoric', 'English Novel', 'Political Science'],
        'genres': ['Fiction', 'Science Fiction', 'Dystopian Fiction', 'Political Fiction'],
        'depositAmount': 180,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'isbn': '978-0141439518',
        'description': 'One of the most beloved novels in the English language, this witty romance follows Elizabeth Bennet as she navigates issues of manners, morality, and marriage in early 19th-century England. Her spirited clash with the proud Mr. Darcy has captivated readers for over two centuries.',
        'coverImageUrl': 'https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg',
        'ownerType': 'business',
        'categories': ['Literature & Rhetoric', 'English Novel', 'English Literature'],
        'genres': ['Fiction', 'Classic & Literary Fiction', 'Romance', 'Historical Romance'],
        'depositAmount': 150,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // Natural Sciences - 2 books
      {
        'title': 'A Brief History of Time',
        'author': 'Stephen Hawking',
        'isbn': '978-0553380163',
        'description': 'Stephen Hawking\'s landmark work explores the nature of time, the Big Bang, black holes, and the search for a unified theory of physics. Written for non-specialists, this book makes complex cosmological concepts accessible to general readers while pondering the deepest questions about our universe.',
        'coverImageUrl': 'https://covers.openlibrary.org/b/isbn/9780553380163-L.jpg',
        'ownerType': 'business',
        'categories': ['Natural Sciences & Mathematics', 'Physics', 'Astronomy'],
        'genres': ['Nonfiction', 'Popular Science'],
        'depositAmount': 250,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'The Selfish Gene',
        'author': 'Richard Dawkins',
        'isbn': '978-0198788607',
        'description': 'A revolutionary look at evolution from the gene\'s point of view. Dawkins explains how genes drive the evolution of life and introduces the concept of "memes" as units of cultural transmission. This influential work changed how we understand natural selection and animal behavior.',
        'coverImageUrl': 'https://covers.openlibrary.org/b/isbn/9780198788607-L.jpg',
        'ownerType': 'business',
        'categories': ['Natural Sciences & Mathematics', 'Life Sciences & Biology', 'Genetics & Evolution'],
        'genres': ['Nonfiction', 'Popular Science'],
        'depositAmount': 220,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    print('Adding ${sampleBooks.length} sample books to Firestore...');

    for (final book in sampleBooks) {
      final docRef = await booksCollection.add(book);
      print('Added: ${book['title']} (ID: ${docRef.id})');
    }

    print('Done! ${sampleBooks.length} books added successfully.');
  }
}
