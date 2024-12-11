<script setup>
import { ref, computed, watch, onMounted } from "vue"; // Import onMounted
import { Head, router } from "@inertiajs/vue3";
import { debounce } from "lodash";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import {
    LayoutDashboardIcon,
    EyeIcon,
    Search as LucideSearchIcon,
    Book as LucideBookIcon,
    BookOpen,
    BookMarked,
    Users,
} from "lucide-vue-next";

// Props
const props = defineProps({
    auth: Object,
    users: Array,
    roles: Array,
    books: Array,
    searchedbooks: Array,
    borrowLogs: Array,
    filteredBooks: Array,
    summary: {
    type: Object,
    required: true,
  },
});

// Reactive states
const searchQuery = ref("");
const filteredBooks = ref([...props.books]); 
const users = ref(props.users || []);
const cachedRoles = ref(props.roles || []);
const books = ref(props.books || []);
const borrowLogs = ref(props.borrowLogs || []);

// Get Role function
const getRole = (roleId) => {
    // Ensure cachedRoles is an array
    if (!Array.isArray(cachedRoles.value)) {
        console.error("cachedRoles is not iterable:", cachedRoles.value);
        return "Unknown";
    }
    const role = cachedRoles.value.find((role) => role.id === roleId);
    return role ? role.user_type : "Unknown";
};

// User profile state
const user = ref({
    avatar: "/images/image.png",
});

// Borrow Book function
const borrowBook = (book) => {
    // Check if the user has already borrowed the book
    const borrowedBook = borrowLogs.value.find(
        (log) => log.current_status === "pending" && log.book_id === book.id
    );

    if (borrowedBook) {
        // If the user has already borrowed the book, show an alert and return
        alert(`You have already borrowed: ${book.title}`);
        return;
    }

    // Ask for user confirmation before borrowing the book
    const confirmBorrow = confirm(
        `Do you want to borrow this book: ${book.title}?`
    );
    if (!confirmBorrow) {
        return; // Exit if the user cancels
    }

    // Proceed with borrowing the book
    router.post(
        route("user.borrowBook"),
        {
            users_id: props.auth.user.id,
            book_id: book.id,
        },
        {
            onSuccess: () => {
                alert(`You have successfully borrowed: ${book.title}`);
            },
            onError: () => {
                alert("There was an error borrowing the book. Please try again.");
            },
        }
    );
};



// Debounced search function
const debouncedSearch = debounce((newQuery) => {
    if (newQuery.trim()) {
        filteredBooks.value = props.books.filter((book) =>
            book.title.toLowerCase().includes(newQuery.toLowerCase()) ||
            book.author_name.toLowerCase().includes(newQuery.toLowerCase()) ||
            book.category.toLowerCase().includes(newQuery.toLowerCase()) ||
            book.genre.toLowerCase().includes(newQuery.toLowerCase())
        );
    } else {
        filteredBooks.value = [...props.books]; // Reset to default
    }
}, 300);


// Watch for changes in searchQuery
watch(searchQuery, (newQuery) => {
    debouncedSearch(newQuery); // Always run the debounced function
});



// On Mounted Hooks
onMounted(() => {
    console.log("Borrow Logs:", props.borrowLogs); // Inspect the data
    borrowLogs.value = [...(props.borrowLogs || [])];
});

onMounted(() => {
    console.log("Books Logs:", props.books); // Inspect the data
    books.value = [...(props.books || [])];
});
</script>

<template>
    <Head title="User Dashboard" />
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
            <!-- Sidebar -->
            <aside
                class="w-full lg:w-1/4 bg-[#E5E1DA] p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black h-screen"
            >
                <!-- User Info Section -->
                <div class="flex flex-col items-center mb-13 pb-16">
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
            <main class="w-full md:w-3/4 p-4 md:p-8">
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
                            <h3 class="text-lg font-semibold text-gray-700">
                                Total Books
                            </h3>
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
                            <h3 class="text-lg font-semibold text-gray-700">
                                Active Users
                            </h3>
                            <p class="text-2xl font-bold text-gray-900">
                                {{ summary.total_users_role_1 }}
                            </p>
                        </div>
                    </div>
                </section>

                <!-- Search Results Display -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Search Box Column -->
                    <div
                        class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-lg border border-black mb-6 max-h-[450px] overflow-y-auto origin-top-left"
                    >
                        <h3 class="text-xl font-semibold text-gray-800">
                            Search Results
                        </h3>
                        <ul class="mt-4 space-y-2">
                            <li
                                v-for="book in filteredBooks"
                                :key="book.id"
                                class="p-4 bg-white rounded-md shadow-md flex justify-between items-center"
                            >
                                <div>
                                    <p class="font-semibold">
                                        {{ book.title }}
                                    </p>
                                    <p class="text-gray-500">
                                        {{ book.author_name }}
                                    </p>
                                    <p class="text-gray-400">
                                        <strong>Category & Genre:</strong>
                                        {{ book.category }}, {{ book.genre }}
                                    </p>
                                    <p class="text-gray-400">
                                        <strong>Year Published:</strong>
                                        {{ book.year_published }}
                                    </p>
                                </div>
                                <button
                                    @click="borrowBook(book)"
                                    class="px-4 py-2 bg-black text-white rounded hover:bg-neutral-700 transition"
                                >
                                    Borrow
                                </button>
                            </li>
                        </ul>
                        <p v-if="books.length === 0" class="text-gray-500">
                            No books found.
                        </p>
                    </div>

                    <!-- Borrow Logs Column -->
                    <div
                        class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-lg border border-black overflow-y-auto max-h-[450px] origin-top-right"
                    >
                        <h3 class="text-xl font-semibold text-gray-800">
                            Borrow Logs
                        </h3>
                        <ul class="mt-4 space-y-2">
                            <li
                                v-for="(log, index) in borrowLogs"
                                :key="index"
                                :class="{
                                    'border-green-500':
                                        log.current_status === 'accepted',
                                    'border-blue-500':
                                        log.current_status === 'returned',
                                    'border-red-500':
                                        log.current_status === 'denied',
                                    'border-gray-300':
                                        log.current_status !== 'accepted' &&
                                        log.current_status !== 'returned',
                                }"
                                class="p-2 bg-white rounded-md shadow-md border-2"
                            >
                                <div>
                                    <p class="font-semibold">
                                        {{ log.book_title }}
                                    </p>
                                    <p class="text-gray-500">
                                        {{ log.book_author }}
                                    </p>
                                    <p class="text-gray-400">
                                        <strong>Copy ID:</strong>
                                        {{ log.copy_id }}
                                    </p>
                                    <p class="text-gray-400">
                                        <strong>Borrowed On:</strong>
                                        {{ log.date_borrowed }}
                                    </p>
                                    <p class="text-gray-400">
                                        <strong>Return Date:</strong>
                                        {{ log.return_date || "N/A" }}
                                    </p>
                                    <p class="text-gray-400">
                                        <strong>Current Status:</strong>
                                        {{ log.current_status }}
                                    </p>
                                </div>
                            </li>
                        </ul>
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
