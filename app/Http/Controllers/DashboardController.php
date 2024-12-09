<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;


use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function librarySummary()
{
    $summary = DB::table('library_summary')->first();

    return Inertia::render('Dashboard', [
        'summary' => $summary,
    ]);
}
}
