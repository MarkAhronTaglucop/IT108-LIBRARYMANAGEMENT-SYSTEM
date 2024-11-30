<script setup>
import { ref, computed } from "vue";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { Head } from "@inertiajs/vue3";
import { LayoutDashboardIcon, EyeIcon, PlusIcon } from "lucide-vue-next";

const user = ref({
  avatar: "/images/image.png",
  role: "Librarian",
});

const searchQuery = ref("");
const books = ref([
  { title: "The Great Gatsby", author: "F. Scott Fitzgerald" },
  { title: "To Kill a Mockingbird", author: "Harper Lee" },
  { title: "1984", author: "George Orwell" },
]);

const addLogs = ref([]);
const newBookTitle = ref("");
const newBookAuthor = ref("");
const showAddBookModal = ref(false);
const editingBook = ref(null); // Variable to hold the book being edited

const filteredBooks = computed(() => {
  return books.value.filter((book) =>
    book.title.toLowerCase().includes(searchQuery.value.toLowerCase())
  );
});

// Add or edit book function
const saveBook = () => {
  if (editingBook.value) {
    // Editing an existing book
    editingBook.value.title = newBookTitle.value;
    editingBook.value.author = newBookAuthor.value;
    addLogs.value.push(`Edited: ${newBookTitle.value} by ${newBookAuthor.value}`);
  } else {
    // Adding a new book
    books.value.push({ title: newBookTitle.value, author: newBookAuthor.value });
    addLogs.value.push(`Added: ${newBookTitle.value} by ${newBookAuthor.value}`);
  }

  // Reset fields and close modal
  newBookTitle.value = "";
  newBookAuthor.value = "";
  editingBook.value = null;
  showAddBookModal.value = false;
};

// Edit book function to populate the modal with the book's details
const editBook = (book) => {
  editingBook.value = book;
  newBookTitle.value = book.title;
  newBookAuthor.value = book.author;
  showAddBookModal.value = true;
};

// Delete book function
const deleteBook = (book) => {
  const index = books.value.indexOf(book);
  if (index !== -1) {
    books.value.splice(index, 1);
    addLogs.value.push(`Deleted: ${book.title} by ${book.author}`);
  }
};
</script>

<template>
  <Head title="Dashboard" />
  <AuthenticatedLayout>
    <template #header>
      <h2 class="text-xl font-semibold leading-tight text-gray-800 flex items-center justify-between">
        <span>Library Management</span>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search books..."
          class="px-4 py-2 w-64 border rounded-md text-gray-800 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
      </h2>
    </template>

    <div class="flex flex-col md:flex-row h-screen bg-gray-100">
      <!-- Sidebar -->
      <aside class="w-full lg:w-1/4 bg-gray-200 p-4 lg:p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black">
        <div class="flex flex-col items-center mb-6">
          <img :src="user.avatar" :alt="user.name" class="w-20 h-20 lg:w-24 lg:h-24 rounded-full border-2 border-black mb-2" />
          <div class="text-center">
            <h2 class="text-lg lg:text-2xl font-bold text-gray-800">{{ $page.props.auth.user.name }}</h2>
            <p class="text-sm lg:text-base text-gray-600">{{ $page.props.auth.user.email }}</p>
            <p class="text-sm lg:text-base text-gray-500">{{ user.role }}</p>
          </div>
        </div>
      </aside>

      <!-- Main Content -->
      <main class="w-full md:w-3/4 p-4 md:p-8">
        <h1 class="text-2xl md:text-3xl font-bold mb-4 text-gray-800 flex items-center">
          <LayoutDashboardIcon class="w-6 md:w-8 h-6 md:h-8 mr-2" />
          Dashboard
        </h1>

        <!-- Add Book Button -->
        <div class="mb-4 flex justify-end">
          <button
            @click="showAddBookModal = true"
            class="px-4 py-2 bg-black text-white rounded hover:bg-green-700 transition flex items-center"
          >
            <PlusIcon class="w-5 h-5 mr-2" />
            Add Book
          </button>
        </div>

        <!-- Modal for Adding or Editing Book -->
        <div v-if="showAddBookModal" class="fixed inset-0 bg-gray-800 bg-opacity-50 flex items-center justify-center">
          <div class="bg-white p-6 rounded-lg shadow-lg w-96">
            <h3 class="text-xl font-bold mb-4">{{ editingBook ? "Edit Book" : "Add New Book" }}</h3>

            <!-- Book Title -->
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Book Title</label>
              <input
                v-model="newBookTitle"
                type="text"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter book title"
              />
            </div>

            <!-- Author -->
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Author</label>
              <input
                v-model="newBookAuthor"
                type="text"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter author's name"
              />
            </div>

            <!-- Modal Buttons -->
            <div class="flex justify-end">
              <button
                @click="saveBook"
                class="px-4 py-2 bg-black text-white rounded hover:bg-neutral-700 transition mr-2"
              >
                {{ editingBook ? "Save Changes" : "Add Book" }}
              </button>
              <button
                @click="showAddBookModal = false"
                class="px-4 py-2 bg-white  text-black rounded hover:bg-gray-300 transition"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>

        <!-- Search Results Display -->
        <div class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black mb-6">
          <h3 class="text-xl font-semibold text-gray-800">Search Results</h3>
          <ul class="mt-4 space-y-2">
            <li v-for="book in filteredBooks" :key="book.title" class="p-4 bg-white rounded-md shadow-md">
              <div class="flex justify-between">
                <div>
                  <p class="font-semibold">{{ book.title }}</p>
                  <p class="text-gray-500">{{ book.author }}</p>
                </div>
                <div class="flex space-x-2">
                  <button
                    @click="editBook(book)"
                    class="text-sm text-blue-500 hover:underline"
                  >
                    Edit
                  </button>
                  <button
                    @click="deleteBook(book)"
                    class="text-sm text-red-500 hover:underline"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </li>
          </ul>
          <p v-if="filteredBooks.length === 0" class="text-gray-500">No books found.</p>
        </div>

        <!-- Add Logs -->
        <div class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black h-64 overflow-y-auto">
          <h3 class="text-xl font-semibold text-gray-800">Add Logs</h3>
          <ul class="mt-4 space-y-2">
            <li v-for="(log, index) in addLogs" :key="index" class="p-2 bg-white rounded-md shadow-md">
              {{ log }}
            </li>
          </ul>
        </div>
      </main>
    </div>
  </AuthenticatedLayout>
</template>
