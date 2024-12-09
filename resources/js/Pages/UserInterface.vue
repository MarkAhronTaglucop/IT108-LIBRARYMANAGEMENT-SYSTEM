<script setup>
import { ref, computed, watch, onMounted } from "vue"; // Import onMounted
import { Head, router } from "@inertiajs/vue3";
import { debounce } from "lodash";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { LayoutDashboardIcon, EyeIcon, Search as LucideSearchIcon, Book as LucideBookIcon, BookOpen, BookMarked, Users } from "lucide-vue-next";

//static rani siya for fetching
const totalBooks = ref(150);
const borrowedBooks = ref(45);
const activeUsers = ref(78);


// Props
const props = defineProps({
    auth: Object,
    users: Array,
    roles: Array,
    books: Array,
    searchedbooks: Array,
    borrowLogs: Array, // Add this
    filteredBooks: Array,
});

const borrowBook = async (book) => {
    try {
        // Ask for user confirmation before borrowing
        const confirmBorrow = confirm(
            `Do you want to borrow this book: ${book.title}?`
        );
        if (!confirmBorrow) return; // Exit if the user cancels

        // Check if the user has already borrowed the book
        const hasBorrowed = props.borrowLogs.some(
            (log) =>
                log.users_id === props.auth.user.id && log.book_id === book.id
        );

        if (hasBorrowed) {
            alert(`You already borrowed: ${book.title}`);
            return; // Exit if the book is already borrowed
        }

        // Proceed with borrowing if the book is not borrowed
        await router.post(route("user-dashboard"), {
            users_id: props.auth.user.id,
            book_id: book.id,
        });

        // Successful borrowing
        borrowLogs.value.push(
            `Successfully borrowed: ${book.title} by ${book.author_name}`
        );
        alert(`You successfully borrowed: ${book.title}`);

        // Refresh the page
        window.location.reload();
    } catch (error) {
        console.error(error);
        const errorMessage =
            error.response?.data?.message || `Failed to borrow: ${book.title}`;
        borrowLogs.value.push(errorMessage);
        alert(errorMessage);
    }
};

// Reactive states
const searchQuery = ref("");
const filteredBooks = ref(props.filteredBooks || []);
const users = ref(props.users || []);
const cachedRoles = ref(props.roles || []);
const books = ref(props.books || []);
const borrowLogs = ref(props.borrowLogs || []);

// Helper function to get role by ID
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
            route("user.search"),
            { searchQuery: newQuery },
            { preserveState: true, preserveScroll: true }
        );
    }
}, 300);

// Watch for changes in searchQuery
watch(searchQuery, (newQuery) => {
    if (!newQuery.trim()) {
        filteredBooks.value = Array.isArray(props.books)
            ? [...props.books]
            : [];
        router.get(route("user-dashboard"), {}, { preserveState: true });
    } else {
        debouncedSearch(newQuery);
    }
});

// Watch for updates in searched books
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

// onMounted hook for logging borrowLogs and books
onMounted(() => {
    borrowLogs.value = [...(props.borrowLogs || [])];
    books.value = [...(props.books || [])];
});
</script>

<template>
    <Head title="User Dashboard" />
    <AuthenticatedLayout>
      <header class="bg-[#E5E1DA] shadow p-4 lg:p-6 border-b border-black">
    <div class="flex justify-between items-center">
      <h2 class="text-xl font-semibold leading-tight text-gray-800 flex items-center">
        <!-- Book Icon from Lucide -->
        <LucideBookIcon class="w-5 h-5 mr-2 text-gray-800" />
        <span>Library Management</span>
      </h2>
      <div class="relative">
        <!-- Search Icon using Lucide -->
        <LucideSearchIcon
          class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-500"
        />
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search books..."
          class="px-4 py-2 pl-10 w-64 border rounded-md text-gray-800 focus:outline-none focus:ring-2 focus:ring-indigo-500 ml-auto"
        />
      </div>
    </div>
  </header>

        <div class="flex flex-col md:flex-row bg-[#F1F0E8] min-h-screen">
            <!-- Sidebar -->
            <aside
                class="w-full lg:w-1/4 bg-[#E5E1DA] p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black"
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
                                {{ totalBooks }}
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
                                {{ borrowedBooks }}
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
                                {{ activeUsers }}
                            </p>
                        </div>
                    </div>
                </section>

                <!-- Search Results Display -->
                <div
                    class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black mb-6 max-h-64 overflow-y-auto"
                >
                    <h3 class="text-xl font-semibold text-gray-800">
                        Search Results
                    </h3>
                    <ul class="mt-4 space-y-2">
                        <li
                            v-for="book in books.filter(
                                (book) => book.num_copies > 1
                            )"
                            :key="book.id"
                            class="p-4 bg-white rounded-md shadow-md flex justify-between items-center"
                        >
                            <div>
                                <p class="font-semibold">{{ book.title }}</p>
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

                <!-- Borrow Logs -->
                <div
                    class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black h-64 overflow-y-auto max-h-64"
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
                                    <strong>Copy ID:</strong> {{ log.copy_id }}
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
            </main>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
/* Webkit Browsers */
::-webkit-scrollbar {
    width: 12px;
    height: 12px;
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
    border-radius: 50px;
    border: 3px solid #f1f1f1;
}

::-webkit-scrollbar-thumb:hover {
    background-color: #555;
}
</style>
