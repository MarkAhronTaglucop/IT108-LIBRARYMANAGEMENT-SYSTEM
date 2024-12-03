<script setup>
import { ref, computed, watch } from "vue";
import { Head, router } from "@inertiajs/vue3";
import { debounce } from "lodash";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { LayoutDashboardIcon, EyeIcon, PlusIcon } from "lucide-vue-next";

// Props
const props = defineProps({
  users: Array,
  roles: Array,
  books: Array,
  searchedbooks: Array,
});

// Reactive states
const users = ref([...props.users]);
const searchQuery = ref("");
const filteredBooks = ref([]); // Store the books after filtering
const cachedRoles = ref([...props.roles]);

// Initialize filteredBooks safely
filteredBooks.value = Array.isArray(props.books) ? [...props.books] : [];

// Get role function
const getRole = (roleId) => {
  const role = cachedRoles.value.find((role) => role.id === roleId);
  return role ? role.user_type : "Unknown";
};

// User profile state
const user = ref({
  avatar: "/images/image.png",
});

// Debounced search function
const debouncedSearch = debounce(async (newQuery) => {
  if (newQuery.trim()) {
    // Perform backend search only if query is not empty
    await router.get(
      route("librarian.search"),
      { searchQuery: newQuery },
      { preserveState: true, preserveScroll: true }
    );
  }
}, 300);

// Watch for changes in searchQuery
watch(searchQuery, (newQuery, oldQuery) => {
  if (!newQuery.trim()) {
    // Reset to all books when the query is empty
    filteredBooks.value = Array.isArray(props.books) ? [...props.books] : [];
    router.get(route("librarian-dashboard"), {}, { preserveState: true }); // Clear query params
  } else if (oldQuery.length === 1 && newQuery.length === 0) {
    // Handle fast deletion to prevent "t" from persisting
    debouncedSearch.cancel(); // Cancel any pending debounce calls
    filteredBooks.value = Array.isArray(props.books) ? [...props.books] : [];
    router.get(route("librarian-dashboard"), {}, { preserveState: true });
  } else {
    debouncedSearch(newQuery);
  }
});

// Watch for backend updates to searchedbooks
watch(
  () => props.searchedbooks,
  (newBooks) => {
    filteredBooks.value =
      Array.isArray(newBooks) && newBooks.length > 0
        ? newBooks
        : Array.isArray(props.books)
        ? [...props.books]
        : [];
  },
  { immediate: true }
);

// Add, edit, and delete functionalities remain untouched
const addLogs = ref([]);
const newBookTitle = ref("");
const newBookAuthor = ref("");
const newBookCategory = ref(""); // Added category input field
const newBookYearPub = ref("");  // Added year published input field
const showAddBookModal = ref(false);
const editingBook = ref(null);

const saveBook = () => {
  if (editingBook.value) {
    editingBook.value.title = newBookTitle.value;
    editingBook.value.author = newBookAuthor.value;
    editingBook.value.category = newBookCategory.value;
    editingBook.value.yearPub = newBookYearPub.value;
    addLogs.value.push(`Edited: ${newBookTitle.value} by ${newBookAuthor.value}`);
  } else {
    filteredBooks.value.push({ title: newBookTitle.value, author: newBookAuthor.value });
    addLogs.value.push(`Added: ${newBookTitle.value} by ${newBookAuthor.value}`);
  }

  newBookTitle.value = "";
  newBookAuthor.value = "";
  newBookCategory.value = "";
  newBookYearPub.value = "";
  editingBook.value = null;
  showAddBookModal.value = false;
};

const editBook = (book) => {
  editingBook.value = book;
  newBookTitle.value = book.title;
  newBookAuthor.value = book.author;
  newBookCategory.value = book.category;
  newBookYearPub.value = book.yearPub;
  showAddBookModal.value = true;
};

const deleteBook = (book) => {
  const index = filteredBooks.value.indexOf(book);
  if (index !== -1) {
    filteredBooks.value.splice(index, 1);
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
            <p class="font-bold text-sm lg:text-base text-gray-500">{{ getRole($page.props.auth.user.role_id) }}</p>
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

            <!-- Book Informations -->
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Book Title</label>
              <input v-model="newBookTitle" type="text" class="mt-1 p-2 w-full border rounded" placeholder="Enter book title" />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Author</label>
              <input v-model="newBookAuthor" type="text" class="mt-1 p-2 w-full border rounded" placeholder="Enter author's name" />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Category</label>
              <input v-model="newBookCategory" type="text" class="mt-1 p-2 w-full border rounded" placeholder="Enter book category" />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Year Published</label>
              <input v-model="newBookYearPub" type="number" class="mt-1 p-2 w-full border rounded" placeholder="Enter publication year" />
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
        <div class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black mb-6 max-h-64 overflow-y-auto">
          <h3 class="text-xl font-semibold text-gray-800">Search Results</h3>
          <ul class="mt-4 space-y-2">
            <li v-for="book in filteredBooks" :key="book.id" class="p-4 bg-white rounded-md shadow-md">
              <div class="flex justify-between">
                <div>
                  <p class="font-semibold">{{ book.title }}</p>
                  <p class="text-gray-500">{{ book.author_name }}</p>
                  <p class="text-gray-500"> <strong>Category:</strong> {{ book.category }}</p> <!-- Display category -->
                  <p class="text-gray-500"> <strong>Year Published:</strong> {{ book.year_published }}</p> <!-- Display year published -->
                  <p class="text-gray-500"> <strong>Number of copies:</strong> {{ book.num_copies }}</p> 
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
        <div class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black h-64 overflow-y-auto max-h-64 max-h-64 overflow-y-auto">
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
