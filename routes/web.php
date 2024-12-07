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
    Route::get('/user-dashboard', [UserController::class, 'display_info'])->name('user-dashboard');
    Route::get('/user-dashboard/search', [UserController::class, 'search'])->name('user.search');
    Route::post('/user-dashboard', [UserController::class, 'borrowBook'])->name('user.borrowBook');
    Route::get('/user-dashboard/logs', [UserController::class, 'borrowLogs'])->name('user-dashboard.logs');


    Route::middleware(['librarian'])->group(function () {
        Route::get('/librarian-dashboard', [LibrarianController::class, 'display_info'])->name('librarian-dashboard');
        Route::get('/librarian-dashboard/search', [LibrarianController::class, 'search'])->name('librarian.search');
        Route::patch('/librarian-dashboard/update/{borrowedBook}', [LibrarianController::class, 'updateStatus'])->name('librarian-dashboard.update');
        Route::put('/librarian-dashboard/update/{id}', [LibrarianController::class, 'updateBook'])->name('librarian.update');
        Route::post('/librarian-dashboard/destroy/{id}', [LibrarianController::class, 'destroy'])->name('librarian.destroy');
        Route::put('/librarian-dashboard/add', [LibrarianController::class, 'store'])->name('librarian.add');
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
