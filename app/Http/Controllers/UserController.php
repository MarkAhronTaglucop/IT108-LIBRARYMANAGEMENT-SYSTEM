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
        $userId = $request->user()->id;
        $borrowLogs = DB::select('SELECT * FROM get_borrowed_books_by_user(?)', [$userId]);
        $books = DB::select('SELECT * FROM view_books');
        $summary = DB::table('library_summary')->first();
        $users = User::all();
        $roles = DB::table('roles')->get();

        $user = $request->user()->load('role');
        return Inertia::render('UserInterface', [
            'auth' => [
                'user' => $user,
                'roles' => $roles,
            ],
            'borrowLogs' => $borrowLogs,
            'books' => $books,
            'users' => $users,
            'roles' => $roles,
            'summary' => $summary,
        ]);
    }


    // public function search(Request $request)
    // {
    //     $searchQuery = $request->input('searchQuery', '');

    //     if (empty($searchQuery)) {
    //         return Inertia::render('UserInterface', [
    //             'searchedbooks' => []
    //         ]);
    //     }

    //     try {
    //         $searchedbooks = DB::select('SELECT * FROM SearchBooksByTitle(?)', [$searchQuery]);
    //     } catch (\Exception $e) {
    //         return Inertia::render('UserInterface', [
    //             'searchedbooks' => [],
    //             'error' => $e->getMessage()
    //         ]);
    //     }

    //     return Inertia::render('UserInterface', [
    //         'searchedbooks' => $searchedbooks
    //     ]);
    // }



    public function borrowBook(Request $request)
    {
        $request->validate([
            'users_id' => 'required|integer|exists:users,id',
            'book_id' => 'required|integer|exists:books,id',
        ]);
    
        $usersId = $request->input('users_id');
        $bookId = $request->input('book_id');
    
        try {
            // Call the database function to borrow the book
            DB::statement('SELECT insert_borrowed_book(?, ?)', [$usersId, $bookId]);
    
            return redirect()->route('user-dashboard')->with([
                'success' => true,
                'message' => 'The book has been successfully borrowed.',
            ]);
        } catch (\Illuminate\Database\QueryException $qe) {
            $errorMessage = $qe->getMessage();
    
            if (strpos($errorMessage, 'User has already borrowed this book') !== false) {
                return redirect()->route('user-dashboard')->with([
                    'success' => false,
                    'message' => 'You have already borrowed this book.',
                ]);
            }
    
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
            return redirect()->route('user-dashboard')->with([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
            ]);
        }
    }
    
}
