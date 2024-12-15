<script setup>
import Checkbox from "@/Components/Checkbox.vue";
import GuestLayout from "@/Layouts/GuestLayout.vue";
import InputError from "@/Components/InputError.vue";
import InputLabel from "@/Components/InputLabel.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import TextInput from "@/Components/TextInput.vue";
import { Head, Link, useForm } from "@inertiajs/vue3";
import { Mail, Lock, User } from "lucide-vue-next";

defineProps({
    canResetPassword: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});

const form = useForm({
    email: "",
    password: "",
    remember: false,
});

const submit = () => {
    form.post(route("login"), {
        onFinish: () => form.reset("password"),
    });
};
</script>

<template>
    <GuestLayout>
        <Head title="Log in" />

        <div v-if="status" class="mb-4 text-sm font-medium text-green-600">
            {{ status }}
        </div>

        <form @submit.prevent="submit">
            <h1 class="text-3xl text-center py-4 text-bold">Welcome Back!</h1>
            <div>
                <InputLabel for="email" value="Email" />

                <div class="relative">
                    <TextInput
                        id="email"
                        type="email"
                        class="mt-1 block w-full pl-10"
                        v-model="form.email"
                        maxlength="100"
                        required
                        autofocus
                        autocomplete="username"
                    />
                    <span class="absolute left-3 top-3 text-gray-500">
                        <Mail size="18" />
                        <!-- Lucide Email Icon -->
                    </span>
                </div>

                <InputError class="mt-2" :message="form.errors.email" />
            </div>

            <div class="mt-4">
                <InputLabel for="password" value="Password" />

                <div class="relative">
                    <TextInput
                        id="password"
                        type="password"
                        class="mt-1 block w-full pl-10"
                        v-model="form.password"
                        maxlength="50"
                        required
                        autocomplete="current-password"
                    />
                    <span class="absolute left-3 top-3 text-gray-500">
                        <Lock size="18" />
                        <!-- Lucide Lock Icon -->
                    </span>
                </div>

                <InputError class="mt-2" :message="form.errors.password" />
            </div>

            <div class="mt-4 block">
                <label class="flex items-center">
                    <Checkbox name="remember" v-model:checked="form.remember" />
                    <span class="ms-2 text-sm text-gray-600">Remember me</span>
                </label>
            </div>

            <div class="mt-4 flex items-center justify-end">
                <Link
                    v-if="canResetPassword"
                    :href="route('password.request')"
                    class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                    Forgot your password?
                </Link>

                <PrimaryButton
                    class="ms-4"
                    :class="{ 'opacity-25': form.processing }"
                    :disabled="form.processing"
                >
                    Log in
                </PrimaryButton>
            </div>
        </form>
    </GuestLayout>
</template>

<style scoped>
/* This ensures the icon stays inside the input field */
.relative {
    position: relative;
}

.absolute {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
}

.pl-10 {
    padding-left: 2.5rem; /* Adjust padding to make room for the icon */
}
</style>
