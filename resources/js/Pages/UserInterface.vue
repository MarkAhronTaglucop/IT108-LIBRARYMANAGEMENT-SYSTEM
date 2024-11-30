<script setup>
import { ref, computed } from "vue";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { Head } from "@inertiajs/vue3";
import { LayoutDashboardIcon, EyeIcon } from "lucide-vue-next";

const user = ref({
    avatar: "/images/image.png",
    role: "User",
});

const functionalities = ref([
    {
        id: "overview",
        name: "View",
        icon: EyeIcon,
        component: () => ({}),
    },
]);

const selectedFunctionality = ref("overview");

const selectFunctionality = (id) => {
    selectedFunctionality.value = id;
};

const currentFunctionalityComponent = computed(() => {
    const functionality = functionalities.value.find(
        (f) => f.id === selectedFunctionality.value
    );
    return functionality ? functionality.component : null;
});

// New state for search query
const searchQuery = ref("");

// Sample books data
const books = ref([
    { title: "The Great Gatsby", author: "F. Scott Fitzgerald" },
    { title: "To Kill a Mockingbird", author: "Harper Lee" },
    { title: "1984", author: "George Orwell" },
]);

// State for borrowed logs
const borrowLogs = ref([]);

// Filtered books based on the search query
const filteredBooks = computed(() => {
    return books.value.filter((book) =>
        book.title.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// Borrow function to add log
const borrowBook = (book) => {
    borrowLogs.value.push(`Borrowed: ${book.title} by ${book.author}`);
};
</script>

<template>
    <Head title="Dashboard" />
    <AuthenticatedLayout>
        <template #header>
            <h2
                class="text-xl font-semibold leading-tight text-gray-800 flex items-center justify-between"
            >
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
            <aside
                class="w-full lg:w-1/4 bg-gray-200 p-4 lg:p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black"
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
                        <p class="text-sm lg:text-base text-gray-500">
                            {{ user.role }}
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

                <!-- Search Results Display -->
                <div
                    class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black mb-6"
                >
                    <h3 class="text-xl font-semibold text-gray-800">
                        Search Results
                    </h3>
                    <ul class="mt-4 space-y-2">
                        <li
                            v-for="book in filteredBooks"
                            :key="book.title"
                            class="p-4 bg-white rounded-md shadow-md flex justify-between items-center"
                        >
                            <div>
                                <p class="font-semibold">{{ book.title }}</p>
                                <p class="text-gray-500">{{ book.author }}</p>
                            </div>
                            <button
                                @click="borrowBook(book)"
                                class="px-4 py-2 bg-black text-white rounded hover:bg-neutral-700 transition"
                            >
                                Borrow
                            </button>
                        </li>
                    </ul>
                    <p v-if="filteredBooks.length === 0" class="text-gray-500">
                        No books found.
                    </p>
                </div>

                <!-- Borrow Logs -->
                <div
                    class="bg-gray-100 p-4 md:p-6 rounded-lg shadow-md border border-black h-64 overflow-y-auto"
                >
                    <h3 class="text-xl font-semibold text-gray-800">
                        Borrow Logs
                    </h3>
                    <ul class="mt-4 space-y-2">
                        <li
                            v-for="(log, index) in borrowLogs"
                            :key="index"
                            class="p-2 bg-white rounded-md shadow-md"
                        >
                            {{ log }}
                        </li>
                    </ul>
                </div>
            </main>
        </div>
    </AuthenticatedLayout>
</template>
