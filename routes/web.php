<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\LibrarianController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});




Route::middleware(['auth', 'setDB'])->group(function () {
    Route::get('/dashboard', function () {
        return Inertia::render(
            'Dashboard'
        );
    })->name('dashboard');

    Route::get('/user-dashboard', [UserController::class, 'users'])->name('user-dashboard');

    Route::middleware(['librarian'])->group(function () {
        Route::get('/librarian-dashboard', [LibrarianController::class, 'users'])->name('librarian-dashboard');
    });

    Route::middleware(['admin'])->group(function () {
        Route::get('/admin-dashboard', [AdminController::class, 'users'])->name('admin-dashboard');
        Route::put('/admin-users/{user}', [AdminController::class, 'updateUserRole'])->name('admin.updateUserRole');
        Route::delete('/admin-users/{user}', [AdminController::class, 'deleteUser'])->name('admin.deleteUser');
    });
});







Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__ . '/auth.php';
