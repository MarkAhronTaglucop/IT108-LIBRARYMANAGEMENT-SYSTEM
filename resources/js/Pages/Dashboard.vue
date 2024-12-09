<script setup>
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { Head } from "@inertiajs/vue3";
import {
    BookOpen,
    Search,
    Users,
    BookMarked,
    Clock,
    TrendingUp,
    Calendar,
    Bell,
    Settings,
    LogOut,
    LayoutDashboardIcon,
} from "lucide-vue-next";
import BookCard from "@/Components/BookCard.vue";
import { ref } from "vue";

// Simulated dynamic data
const totalBooks = ref(150);
const borrowedBooks = ref(45);
const activeUsers = ref(78);
const notifications = ref([
    {
        id: 1,
        message: "New book added: 'The Midnight Library'",
        time: "2 hours ago",
    },
    {
        id: 2,
        message: "Overdue book: 'To Kill a Mockingbird'",
        time: "1 day ago",
    },
]);

const popularGenres = ref([
    { name: "Fiction", percentage: 40 },
    { name: "Non-Fiction", percentage: 30 },
    { name: "Science", percentage: 15 },
    { name: "History", percentage: 10 },
    { name: "Others", percentage: 5 },
]);

const recentActivities = ref([
    {
        action: "Borrowed",
        book: "The Great Gatsby",
        user: "John Doe",
        time: "3 hours ago",
    },
    { action: "Returned", book: "1984", user: "Jane Smith", time: "1 day ago" },
    {
        action: "Reserved",
        book: "To Kill a Mockingbird",
        user: "Alice Johnson",
        time: "2 days ago",
    },
]);
</script>

<template>
    <Head title="Library Dashboard" />

    <AuthenticatedLayout>
        <div class="min-h-screen bg-[#F1F0E8]">
            <!-- Sidebar -->

            <!-- Main Content -->
            <div class="flex-1 p-8 overflow-auto">
                <!-- Header -->
                <header class="flex justify-between items-center mb-8">
                    <!-- Dashboard Title and Icon -->
                    <div class="flex items-center space-x-2">
                        <LayoutDashboardIcon class="w-8 h-8 text-gray-800" />
                        <h2 class="text-3xl font-bold text-gray-800">
                            Dashboard
                        </h2>
                    </div>

                    <!-- Search Input -->
                    <!-- <div class="flex items-center space-x-4">
                        <div class="relative">
                            <input
                                type="text"
                                class="w-64 px-4 py-2 rounded-lg text-black border border-gray-300"
                                placeholder="Search books..."
                            />
                            <Search
                                class="absolute right-3 top-2.5 text-gray-500"
                            />
                        </div>
                    </div> -->
                </header>

                <!--Pwede ko pa bind sa logs para ma display pls fetch lungs-->
                <!-- Dashboard Summary -->
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

                <!-- Most Read Books -->
                <section class="bg-white rounded-lg shadow-md p-6 mb-8">
                    <h2
                        class="text-2xl font-semibold text-gray-800 mb-6 flex items-center"
                    >
                        <TrendingUp class="w-6 h-6 mr-2 text-[#89A8B2]" />
                        Most Read Books This Month
                    </h2>
                    <div
                        class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
                    >
                        <BookCard
                            v-for="book in [
                                {
                                    title: 'Educated',
                                    author: 'Tara Westover',
                                    category: 'Non-Fiction, Memoir',
                                    year: '2018',
                                    imageUrl:
                                        'https://covers.openlibrary.org/b/id/3703054-L.jpg',
                                },
                                {
                                    title: 'The Great Gatsby',
                                    author: 'F. Scott Fitzgerald',
                                    category: 'Fiction, Tragedy',
                                    year: '1925',
                                    imageUrl:
                                        'https://covers.openlibrary.org/b/id/5302910-L.jpg',
                                },
                                {
                                    title: 'The Lord of the Rings',
                                    author: 'J.R.R. Tolkien',
                                    category: 'Fiction, Fantasy',
                                    year: '1954',
                                    imageUrl:
                                        'https://covers.openlibrary.org/b/id/7222246-L.jpg',
                                },
                                {
                                    title: 'Sapiens: A Brief History of Humankind',
                                    author: 'Yuval Noah Harari',
                                    category: 'Non-Fiction, Anthropology',
                                    year: '2011',
                                    imageUrl:
                                        'https://covers.openlibrary.org/b/id/7064681-L.jpg',
                                },
                            ]"
                            :key="book.title"
                            v-bind="book"
                        />
                    </div>
                </section>

                <!-- Additional Sections -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <!-- Popular Genres -->
                    <section class="bg-white rounded-lg shadow-md p-6">
                        <h2
                            class="text-2xl font-semibold text-gray-800 mb-6 flex items-center"
                        >
                            <BookOpen class="w-6 h-6 mr-2 text-[#89A8B2]" />
                            Popular Genres
                        </h2>
                        <div class="space-y-4">
                            <div
                                v-for="genre in popularGenres"
                                :key="genre.name"
                                class="flex items-center"
                            >
                                <span class="w-24 text-sm text-gray-600">{{
                                    genre.name
                                }}</span>
                                <div
                                    class="flex-1 h-4 bg-gray-200 rounded-full overflow-hidden"
                                >
                                    <div
                                        class="h-full bg-[#89A8B2]"
                                        :style="{
                                            width: `${genre.percentage}%`,
                                        }"
                                    ></div>
                                </div>
                                <span
                                    class="w-12 text-sm text-gray-600 text-right"
                                    >{{ genre.percentage }}%</span
                                >
                            </div>
                        </div>
                    </section>

                    <!-- Pwede ko ba bind sa logs dre koys -->
                    <!-- Recent Activities -->
                    <section class="bg-white rounded-lg shadow-md p-6">
                        <h2
                            class="text-2xl font-semibold text-gray-800 mb-6 flex items-center"
                        >
                            <Clock class="w-6 h-6 mr-2 text-[#89A8B2]" />
                            Recent Activities
                        </h2>
                        <ul class="space-y-4">
                            <li
                                v-for="activity in recentActivities"
                                :key="activity.book"
                                class="flex items-start space-x-3"
                            >
                                <div
                                    :class="{
                                        'bg-green-100 text-green-800':
                                            activity.action === 'Borrowed',
                                        'bg-blue-100 text-blue-800':
                                            activity.action === 'Returned',
                                        'bg-yellow-100 text-yellow-800':
                                            activity.action === 'Reserved',
                                    }"
                                    class="px-2 py-1 rounded text-sm font-medium"
                                >
                                    {{ activity.action }}
                                </div>
                                <div class="flex-1">
                                    <p
                                        class="text-sm font-medium text-gray-900"
                                    >
                                        {{ activity.book }}
                                    </p>
                                    <p class="text-sm text-gray-500">
                                        {{ activity.user }}
                                    </p>
                                </div>
                                <span class="text-sm text-gray-400">{{
                                    activity.time
                                }}</span>
                            </li>
                        </ul>
                    </section>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
/* Webkit Scrollbar styles remain unchanged */
</style>
