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
        // Step 1: Validate the incoming request
        $request->validate([
            'users_id' => 'required|integer',
            'book_id' => 'required|integer',
        ]);

        $usersId = $request->input('users_id');
        $bookId = $request->input('book_id');

        // Step 2: Check if the book and user exist in the database
        $bookExists = DB::table('books')->where('id', $bookId)->exists();
        $userExists = DB::table('users')->where('id', $usersId)->exists();

        if (!$bookExists) {
            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => 'The specified book does not exist.',
            ]);
        }

        if (!$userExists) {
            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => 'The specified user does not exist.',
            ]);
        }

        // Step 3: Attempt to execute the SQL function to borrow the book
        try {
            // Call the database function to borrow the book
            DB::statement('SELECT insert_borrowed_book(?, ?)', [$usersId, $bookId]);

            // Step 4: Redirect with a success message
            return redirect()->route('user-dashboard')->with([
                'success' => true,
                'message' => 'The book has been successfully borrowed.',
            ]);
        } catch (\Illuminate\Database\QueryException $qe) {
            // Handle known SQL-related errors
            $errorMessage = $qe->getMessage();

            // Handle case when the user has already borrowed the book
            if (strpos($errorMessage, 'User has already borrowed this book') !== false) {
                return redirect()->route('user-dashboard')->with([
                    'success' => false,
                    'message' => 'You have already borrowed this book.',
                ]);
            }

            // Handle case when no copies are available
            if (strpos($errorMessage, 'No available copies') !== false) {
                return redirect()->route('user-dashboard')->with([
                    'success' => false,
                    'message' => 'Sorry, there are no available copies of this book.',
                ]);
            }

            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => 'An error occurred while borrowing the book. Please try again.',
            ]);
        } catch (\Exception $e) {
            // Handle general exceptions (e.g., unexpected errors)
            $errorMessage = $e->getMessage();


            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => 'An error occurred: ' . $errorMessage,
            ]);
        }
    }
}
