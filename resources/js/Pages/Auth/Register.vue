<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

// Utility function to sanitize input
const sanitizeInput = (value) => value.replace(/<[^>]*>?/gm, '');

// Define form and validation rules
const form = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
});

const rules = {
    required: (v) => !!v || 'This field is required.',
    fullname: (v) =>
        (v && v.length >= 10 && v.length <= 50) || 'Name must be 10-50 characters long.',
    email: (v) =>
        /^(?:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$/.test(v) ||
        'E-mail must be valid.',
    password: (v) =>
        (v &&
            v.length >= 8 &&
            /[A-Z]/.test(v) &&
            /[a-z]/.test(v) &&
            /[0-9]/.test(v) &&
            /[!@#$%^&*(),.?":{}|<>]/.test(v)) ||
        'Password must be at least 8 characters, including uppercase, lowercase, number, and special character.',
};

// Form submission logic
const submit = () => {
    const errors = {};

    // Name validation
    if (!form.name || form.name.length < 10) {
        errors.name = "Name should be at least 10 characters long";
    }

    // Email validation
    if (!form.email || !/.+@.+\..+/.test(form.email)) {
        errors.email = "E-mail must be valid";
    }

    // Password validation
    if (
        !form.password ||
        form.password.length < 8 ||
        !/[A-Z]/.test(form.password) ||
        !/[a-z]/.test(form.password) ||
        !/[0-9]/.test(form.password) ||
        !/[!@#$%^&*(),.?":{}|<>]/.test(form.password)
    ) {
        errors.password =
            "Password must be at least 8 characters and contain uppercase, lowercase, number, and special character";
    }

    // Password confirmation validation
    if (form.password !== form.password_confirmation) {
        errors.password_confirmation = "Password confirmation does not match";
    }

    form.errors = errors;

    // Stop submission if there are any errors
    if (Object.keys(errors).length > 0) {
        return;
    }

    // Submit the form if validation passes
    form.post(route('register'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
    });
};

</script>

<template>
    <GuestLayout>
        <Head title="Register" />

        <form @submit.prevent="submit">
            <div>
                <InputLabel for="name" value="Name" />
                <TextInput
                    id="name"
                    type="text"
                    class="mt-1 block w-full"
                    v-model="form.name"
                    maxlength="50"
                    required
                    autofocus
                    autocomplete="name"
                />
                <InputError class="mt-2" :message="form.errors.name" />
            </div>

            <div class="mt-4">
                <InputLabel for="email" value="Email" />
                <TextInput
                    id="email"
                    type="email"
                    class="mt-1 block w-full"
                    v-model="form.email"
                    maxlength="100"
                    required
                    autocomplete="username"
                />
                <InputError class="mt-2" :message="form.errors.email" />
            </div>

            <div class="mt-4">
                <InputLabel for="password" value="Password" />
                <TextInput
                    id="password"
                    type="password"
                    class="mt-1 block w-full"
                    v-model="form.password"
                    maxlength="50"
                    required
                    autocomplete="new-password"
                />
                <InputError class="mt-2" :message="form.errors.password" />
            </div>

            <div class="mt-4">
                <InputLabel for="password_confirmation" value="Confirm Password" />
                <TextInput
                    id="password_confirmation"
                    type="password"
                    class="mt-1 block w-full"
                    v-model="form.password_confirmation"
                    maxlength="50"
                    required
                    autocomplete="new-password"
                />
                <InputError class="mt-2" :message="form.errors.password_confirmation" />
            </div>

            <div class="mt-4 flex items-center justify-end">
                <Link
                    :href="route('login')"
                    class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                    Already registered?
                </Link>

                <PrimaryButton
                    class="ms-4"
                    :class="{ 'opacity-25': form.processing }"
                    :disabled="form.processing"
                >
                    Register
                </PrimaryButton>
            </div>
        </form>
    </GuestLayout>
</template>
