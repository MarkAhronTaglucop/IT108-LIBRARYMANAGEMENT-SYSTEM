<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Illuminate\Database\QueryException;

class UserController extends Controller
{

    public function display_info(Request $request)
    {
        // You can fetch whatever data you want to show on the dashboard
        $userId = $request->user()->id;
        $borrowLogs = DB::select('SELECT * FROM get_borrowed_books_by_user(?)', [$userId]);
        $books = DB::select('SELECT * FROM view_books');
        $users = User::all(); // Example for users
        $roles = DB::table('roles')->get(); // Example for roles
    
        $user = $request->user()->load('role'); // Ensure role is loaded
        return Inertia::render('UserInterface', [
            'auth' => [
                'user' => $user,
                'roles' => $roles, // If you need to pass all roles
            ],
            'borrowLogs' => $borrowLogs,
            'books' => $books,
            'users' => $users,
            'roles' => $roles, // If you need to pass all roles
        ]);

    }
    

    public function search(Request $request)
    {
        $searchQuery = $request->input('searchQuery', '');

        if (empty($searchQuery)) {
            return Inertia::render('UserInterface', [
                'searchedbooks' => []
            ]);
        }

        try {
            $searchedbooks = DB::select('SELECT * FROM SearchBooksByTitle(?)', [$searchQuery]);
        } catch (\Exception $e) {
            return Inertia::render('UserInterface', [
                'searchedbooks' => [],
                'error' => $e->getMessage() // Optional: Include error for debugging
            ]);
        }

        return Inertia::render('UserInterface', [
            'searchedbooks' => $searchedbooks
        ]);
    }

    public function borrowBook(Request $request)
    {
        $request->validate([
            'users_id' => 'required|integer',
            'book_id' => 'required|integer',
        ]);
    
        $usersId = $request->input('users_id');
        $bookId = $request->input('book_id');
    
        try {
            // Call the database function to borrow the book
            DB::statement('SELECT insert_borrowed_book(?, ?)', [$usersId, $bookId]);
    
            // Redirect with a success message
            return redirect()->route('user-dashboard')->with([
                'success' => true,
                'message' => 'The book has been successfully borrowed.',
            ]);
        } catch (\Illuminate\Database\QueryException $qe) {
            // Handle SQL-related errors, including the case when the user has already borrowed the book
            $errorMessage = $qe->getMessage();
    
            // Check if the error message indicates that the user has already borrowed the book
            if (strpos($errorMessage, 'You have already borrowed this book.') !== false) {
                // Flash the error message to the session
                return redirect()->route('user-dashboard')->with([
                    'success' => false,
                    'message' => 'You have already borrowed this book.',
                ]);
            }
    
            // Log the error message
            // \Log::error('SQL Exception in borrowBook: ' . $errorMessage);
    
            // Flash a general error message
            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => 'An error occurred while borrowing the book. Please try again.',
            ]);
        } catch (\Exception $e) {
            // Handle general errors
            $errorMessage = $e->getMessage();
            // \Log::error('Exception in borrowBook: ' . $errorMessage);
    
            // Flash the error message to the session
            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => $errorMessage,
            ]);
        }
    }
    
}