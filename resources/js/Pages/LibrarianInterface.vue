<script setup>
import { ref, computed, watch, onMounted } from "vue";
import { Head, router } from "@inertiajs/vue3";
import { debounce } from "lodash";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import {
  LayoutDashboardIcon,
  PlusIcon,
  EyeIcon,
  Search as LucideSearchIcon,
  Book as LucideBookIcon,
  BookOpen,
  BookMarked,
  Users,
} from "lucide-vue-next";

// Props
const props = defineProps({
  users: Array,
  roles: Array,
  books: Array,
  searchedbooks: Array,
  borrowLogs: Array,
  AcceptingLogs: Array,
  acceptlogs: Array,
  summary: {
    type: Object,
    required: true,
  },
});

// Reactive states
const logs = ref([...props.borrowLogs]);
const acceptlogs = ref([...props.AcceptingLogs]);
const users = ref([...props.users]);
const searchQuery = ref("");
const filteredBooks = ref([]);
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
    await router.get(
      route("librarian.search"),
      { searchQuery: newQuery },
      { preserveState: true, preserveScroll: true }
    );
  }
}, 300);

// Watchers
watch(searchQuery, (newQuery, oldQuery) => {
  if (!newQuery.trim()) {
    filteredBooks.value = Array.isArray(props.books) ? [...props.books] : [];
    router.get(route("librarian-dashboard"), {}, { preserveState: true });
  } else if (oldQuery.length === 1 && newQuery.length === 0) {
    debouncedSearch.cancel();
    filteredBooks.value = Array.isArray(props.books) ? [...props.books] : [];
    router.get(route("librarian-dashboard"), {}, { preserveState: true });
  } else {
    debouncedSearch(newQuery);
  }
});

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

onMounted(() => {
  console.log("Borrow Logs:", props.borrowLogs);
  console.log("Accepting Logs:", props.AcceptingLogs);
});

// Methods
const deleteBook = (id) => {
  if (confirm("Are you sure you want to delete this book?")) {
    router.post(route("librarian.destroy", { id }), {
      onSuccess: () => console.log("Book deleted successfully!"),
      onError: (errors) => console.error("Failed to delete book:", errors),
    });
    window.location.reload();
  }
};

// Book management
const showEditBookModal = ref(false);
const bookData = ref({
  id: null,
  title: "",
  category: "",
  genre: "",
  year_published: "",
  number_of_copies: 0,
});

const editBook = (book) => {
  bookData.value = { ...book };
  showEditBookModal.value = true;
};

const saveBook = async () => {
  try {
    await router.put(`/librarian-dashboard/update/${bookData.value.id}`, {
      title: bookData.value.title,
      category: bookData.value.category,
      genre: bookData.value.genre,
      year_published: bookData.value.year_published,
      number_of_copies: bookData.value.num_copies, // Fixed key
    });
    alert("Book updated successfully!");
  } catch (error) {
    console.error("Failed to update book:", error);
    alert("An error occurred while updating the book.");
  } finally {
    showEditBookModal.value = false;
  }
};

const updateStatus = async (borrowedId, newStatusId) => {
  console.log("Updating status for:", borrowedId, "with status:", newStatusId);
  try {
    await router.patch(
      route("librarian-dashboard.update", borrowedId),
      { new_status_id: newStatusId },
      {
        preserveScroll: true,
        onSuccess: () => console.log("Book status updated successfully!"),
        onError: (errors) => console.error("Validation errors:", errors),
      }
    );
    // window.location.reload();
  } catch (error) {
    console.error("Error updating status:", error);
  }
};

const showAddBookModal = ref(false);
const newBookData = ref({
  title: "",
  category: "",
  genre: "",
  year_published: "",
  author_name: "",
  author_country: "",
});

const addBook = async () => {
  try {
    console.log("New Book Data:", newBookData.value);
    await router.post("/librarian-dashboard/add", {
      title: newBookData.value.title,
      category: newBookData.value.category,
      genre: newBookData.value.genre,
      year_published: newBookData.value.year_published,
      author_name: newBookData.value.author_name,
      author_country: newBookData.value.author_country,
    });
    alert("Book added successfully!");
  } catch (error) {
    console.error("Failed to add book:", error);
    alert("An error occurred while adding the book.");
  } finally {
    showAddBookModal.value = false;
  }
};




// Validation methods

// Only allow text and spaces for the Title
const validateTitle = (event) => {
  const value = event.target.value;
  const regex = /^[a-zA-Z\s]*$/; // Only letters and spaces
  if (!regex.test(value)) {
    event.target.value = value.slice(0, -1); // Remove last character if invalid
  }
};

// Only allow text and spaces for Genre
const validateGenre = (event) => {
  const value = event.target.value;
  const regex = /^[a-zA-Z\s]*$/; // Only letters and spaces
  if (!regex.test(value)) {
    event.target.value = value.slice(0, -1); // Remove last character if invalid
  }
};

// Restrict special characters for Category (only letters, numbers, dash, colon, and comma)
const validateCategory = (event) => {
  const value = event.target.value;
  const regex = /^[a-zA-Z0-9\s\-,:]*$/; // Allow letters, numbers, spaces, dash, colon, comma
  if (!regex.test(value)) {
    event.target.value = value.slice(0, -1); // Remove last character if invalid
  }
};

// Limit the number of copies to 9999
const validateCopies = (event) => {
  const value = event.target.value;
  const maxCopies = 9999;
  if (value > maxCopies) {
    event.target.value = maxCopies; // Limit to maxCopies
  }
};
</script>



<template>
  <Head title="Librarian Dashboard" />
  <AuthenticatedLayout>
    <header class="bg-[#E5E1DA] shadow p-4 lg:p-6 border-b border-black">
      <div class="flex justify-between items-center">
        <h2
          class="text-xl font-semibold leading-tight text-gray-800 flex items-center"
        >
          <!-- Book Icon from Lucide -->
          <LucideBookIcon class="w-15 h-15 mr-2 text-gray-800" />
          <span>Library Management</span>
        </h2>
        <div class="relative w-full sm:w-auto">
          <!-- Search Icon using Lucide -->
          <LucideSearchIcon
            class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-500"
          />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search books..."
            class="px-4 py-2 pl-10 w-full sm:w-64 border rounded-md text-gray-800 focus:outline-none focus:ring-2 focus:ring-indigo-500 ml-auto"
          />
        </div>
      </div>
    </header>

    <div class="flex flex-col md:flex-row bg-[#F1F0E8] min-h-screen">
      <!-- Sidebar -->
      <aside
        class="w-full lg:w-1/4 bg-[#E5E1DA] p-4 lg:p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black"
      >
        <div class="flex flex-col items-center mb-6">
          <img
            :src="user.avatar"
            :alt="user.name"
            class="w-20 h-20 lg:w-24 lg:h-24 rounded-full border-2 border-black mb-2"
          />
          <div class="text-center">
            <h2 class="text-lg lg:text-2xl font-bold text-gray-800">
              {{ $page.props.auth.user.name }}
            </h2>
            <p class="text-sm lg:text-base text-gray-600">
              {{ $page.props.auth.user.email }}
            </p>
            <p class="font-bold text-sm lg:text-base text-gray-500">
              {{ getRole($page.props.auth.user.role_id) }}
            </p>
          </div>
        </div>
      </aside>

      <!-- Main Content -->
      <main class="w-full md:w-3/4 p-4 md:p-8 bg-[#F1F0E8]">
        <h1
          class="text-2xl md:text-3xl font-bold mb-4 text-gray-800 flex items-center"
        >
          <LayoutDashboardIcon class="w-6 md:w-8 h-6 md:h-8 mr-2" />
          Dashboard
        </h1>

        <section class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div
            class="bg-white rounded-lg shadow-md p-6 flex items-center space-x-4"
          >
            <div class="bg-blue-100 p-3 rounded-full">
              <BookOpen class="w-8 h-8 text-blue-500" />
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-700">Total Books</h3>
              <p class="text-2xl font-bold text-gray-900">
                {{ summary.total_books }}
              </p>
            </div>
          </div>
          <div
            class="bg-white rounded-lg shadow-md p-6 flex items-center space-x-4"
          >
            <div class="bg-green-100 p-3 rounded-full">
              <BookMarked class="w-8 h-8 text-green-500" />
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-700">
                Books Borrowed
              </h3>
              <p class="text-2xl font-bold text-gray-900">
                {{ summary.total_borrowed_books }}
              </p>
            </div>
          </div>
          <div
            class="bg-white rounded-lg shadow-md p-6 flex items-center space-x-4"
          >
            <div class="bg-purple-100 p-3 rounded-full">
              <Users class="w-8 h-8 text-purple-500" />
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-700">Active Users</h3>
              <p class="text-2xl font-bold text-gray-900">
                {{ summary.total_users_role_1 }}
              </p>
            </div>
          </div>
        </section>

        <!-- Add Book Button -->
        <div class="mb-4 flex justify-end">
          <button
            @click="showAddBookModal = true"
            class="px-4 py-2 bg-black text-white rounded hover:bg-green-700 transition flex items-center"
          >
            <PlusIcon class="w-5 h-5 mr-2" />
            Add Book
          </button>
          <!-- Add Book Modal -->
          <div
            v-if="showAddBookModal"
            class="fixed inset-0 bg-gray-800 bg-opacity-50 flex items-center justify-center"
          >
            <div
              class="bg-white p-6 rounded-lg shadow-lg w-96 h-[90vh] overflow-y-auto"
            >
              <h3 class="text-xl font-bold mb-4">Add New Book</h3>

              <!-- Book Information Form -->
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700"
                  >Book Title:</label
                >
                <input
                  v-model="newBookData.title"
                  type="text"
                  class="mt-1 p-2 w-full border rounded"
                  placeholder="Enter book title"
                  maxlength="100"
                  @input="validateTitle($event)"
                />
              </div>

              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700"
                  >Category:</label
                >
                <input
                  v-model="newBookData.category"
                  type="text"
                  class="mt-1 p-2 w-full border rounded"
                  placeholder="Enter book category"
                  maxlength="50"
                  @input="validateCategory($event)"
                />
              </div>

              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700"
                  >Genre:</label
                >
                <input
                  v-model="newBookData.genre"
                  type="text"
                  class="mt-1 p-2 w-full border rounded"
                  placeholder="Enter book genre"
                  maxlength="50"
                  @input="validateGenre($event)"
                />
              </div>

              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700"
                  >Year Published:</label
                >
                <input
                  v-model="newBookData.year_published"
                  type="date"
                  class="mt-1 p-2 w-full border rounded"
                  maxlength="10"
                />
              </div>

              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700"
                  >Author Name:</label
                >
                <input
                  v-model="newBookData.author_name"
                  type="text"
                  class="mt-1 p-2 w-full border rounded"
                  placeholder="Enter Author Name"
                  maxlength="100"
                  @input="validateGenre($event)"
                />
              </div>

              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700"
                  >Author Country:</label
                >
                <input
                  v-model="newBookData.author_country"
                  type="text"
                  class="mt-1 p-2 w-full border rounded"
                  placeholder="Enter Author Country"
                  maxlength="50"
                  @input="validateGenre($event)"
                />
              </div>

              <!-- Modal Buttons -->
              <div class="flex justify-end">
                <button
                  @click="addBook"
                  class="px-4 py-2 bg-black text-white rounded hover:bg-neutral-700 transition mr-2"
                >
                  Add Book
                </button>
                <button
                  @click="showAddBookModal = false"
                  class="px-4 py-2 bg-white text-black rounded hover:bg-gray-300 transition"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal for Editing Book -->
        <div
          v-if="showEditBookModal"
          class="fixed inset-0 bg-gray-800 bg-opacity-50 flex items-center justify-center"
        >
          <div class="bg-white p-6 rounded-lg shadow-lg w-96">
            <h3 class="text-xl font-bold mb-4">Editing Book</h3>

            <!-- Book Informations -->
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700"
                >Book Title:
              </label>
              <input
                v-model="bookData.title"
                type="text"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter book title"
                maxlength="100"
                @input="validateTitle($event)"
              />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700"
                >Category:</label
              >
              <input
                v-model="bookData.category"
                type="text"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter book category"
                maxlength="50"
                @input="validateCategory($event)"
              />
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700"
                >Genre:</label
              >
              <input
                v-model="bookData.genre"
                type="text"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter Genre"
                maxlength="50"
                @input="validateGenre($event)"
              />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700"
                >Year Published: dd/mm/yyyy</label
              >
              <input
                v-model="bookData.year_published"
                type="date"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter publication year"
                maxlength="10"
              />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700"
                >Copies:</label
              >
              <input
                v-model="bookData.num_copies"
                type="number"
                class="mt-1 p-2 w-full border rounded"
                placeholder="Enter new Copies"
                maxlength="4"
                @input="validateCopies($event)"
              />
            </div>

            <!-- Modal Buttons -->
            <div class="flex justify-end">
              <button
                @click="saveBook"
                class="px-4 py-2 bg-black text-white rounded hover:bg-neutral-700 transition mr-2"
              >
                Save Changes
              </button>
              <button
                @click="showEditBookModal = false"
                class="px-4 py-2 bg-white text-black rounded hover:bg-gray-300 transition"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>

        <div class="flex flex-col md:flex-row gap-6">
          <!-- Search Results Display -->
          <div
            class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black mb-6 w-full md:w-1/3 max-h-[80vh] overflow-y-auto"
          >
            <h3 class="text-xl font-semibold text-gray-800">Search Results</h3>
            <ul class="mt-4 space-y-2">
              <li
                v-for="book in filteredBooks"
                :key="book.id"
                class="p-4 bg-white rounded-md shadow-md"
              >
                <div class="flex justify-between">
                  <div>
                    <p class="font-semibold">
                      {{ book.title }}
                    </p>
                    <p class="text-gray-500">
                      {{ book.author_name }}
                    </p>
                    <p class="text-gray-500">
                      <strong>Category:</strong>
                      {{ book.category }}
                    </p>
                    <p class="text-gray-500">
                      <strong>Year Published:</strong>
                      {{ book.year_published }}
                    </p>
                    <p class="text-gray-500">
                      <strong>Number of copies:</strong>
                      {{ book.num_copies }}
                    </p>
                  </div>
                  <div class="flex space-x-2">
                    <button
                      @click="editBook(book)"
                      class="text-sm text-blue-500 hover:underline"
                    >
                      Edit
                    </button>
                    <button
                      @click="deleteBook(book.id)"
                      class="text-sm text-red-500 hover:underline"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </li>
            </ul>
            <p v-if="filteredBooks.length === 0" class="text-gray-500">
              No books found.
            </p>
          </div>

          <div class="flex flex-col gap-4 w-full md:w-2/3">
            <!-- Accepting Logs -->
            <div
              class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black max-h-[40vh] overflow-y-auto"
            >
              <h4 class="text-lg font-semibold text-gray-700">
                Accepting Logs
              </h4>
              <ul class="mt-2 space-y-2">
                <li
                  v-for="(log, index) in acceptlogs"
                  :key="`accept-${index}` || log.borrowed_id"
                  class="flex justify-between items-center p-2 bg-white rounded-md shadow-md"
                >
                  <div>
                    <p>
                      <strong>Borrowed ID:</strong>
                      {{ log.borrowed_id }}<br />
                      <strong>Book:</strong>
                      {{ log.book_title }}<br />
                      <strong>Borrowed By:</strong>
                      {{ log.user_name }}<br />
                      <strong>Date Borrowed:</strong>
                      {{ log.date_borrowed }}<br />
                      <strong>Current Status:</strong>
                      {{ log.current_status }}<br />
                      <strong>Copy ID:</strong> {{ log.id }}<br />
                      <strong>Return Date:</strong>
                      {{ log.return_date || "N/A" }}<br />
                    </p>
                  </div>
                  <div class="flex gap-2">
                    <button
                      @click="updateStatus(log.borrowed_id, 4)"
                      :disabled="log.current_status === 'accepted'"
                      class="px-3 py-1 text-sm font-medium text-white bg-red-500 rounded hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-green-500"
                    >
                      Deny
                    </button>
                    <button
                      @click="updateStatus(log.borrowed_id, 2)"
                      :disabled="log.current_status === 'accepted'"
                      class="px-3 py-1 text-sm font-medium text-white bg-green-500 rounded hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-green-500"
                    >
                      Accept
                    </button>
                    <button
                      @click="updateStatus(log.borrowed_id, 3)"
                      :disabled="log.current_status === 'pending'"
                      class="px-3 py-1 text-sm font-medium text-white bg-blue-500 rounded hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-blue-500"
                    >
                      Returned
                    </button>
                  </div>
                </li>
              </ul>
              <p v-if="acceptlogs.length === 0" class="text-gray-500">
                No book borrowing logs found.
              </p>
            </div>

            <!-- Borrowed Logs -->
            <div
              class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black max-h-[41vh] overflow-y-auto"
            >
              <h3 class="text-xl font-semibold text-gray-800">Borrow Logs</h3>
              <ul class="mt-4 space-y-2">
                <li
                  v-for="log in logs"
                  :key="log.id"
                  :class="{
                    'border-green-500': log.current_status === 'accepted',
                    'border-blue-500': log.current_status === 'returned',
                    'border-red-500': log.current_status === 'denied',

                    'border-gray-300':
                      log.current_status !== 'accepted' &&
                      log.current_status !== 'returned',
                  }"
                  class="p-2 bg-white rounded-md shadow-md border-2"
                >
                  <p>
                    <strong>Book:</strong>
                    {{ log.book_title }}<br />
                    <strong>Borrowed By:</strong>
                    {{ log.user_name }}<br />
                    <strong>Date Borrowed:</strong>
                    {{ log.date_borrowed }}<br />
                    <strong>Current Status:</strong>
                    {{ log.current_status }}<br />
                    <strong>Copy ID:</strong> {{ log.id }}<br />
                    <strong>Return Date:</strong>
                    {{ log.return_date || "N/A" }}<br />
                  </p>
                </li>
              </ul>
              <p v-if="logs.length === 0" class="text-gray-500">
                No borrow logs found.
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
/* Webkit Browsers */
::-webkit-scrollbar {
  width: 12px;
  height: 12px; /* for horizontal scrollbars */
}

.textsy textarea {
  resize: none;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 50px;
}

::-webkit-scrollbar-thumb {
  background-color: #888;
  border-radius: 50px; /* Circular border */
  border: 3px solid #f1f1f1; /* Adds space around thumb */
}

::-webkit-scrollbar-thumb:hover {
  background-color: #555;
}
</style>
