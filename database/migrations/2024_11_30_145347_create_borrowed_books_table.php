<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
            Schema::create('borrowed_books', function (Blueprint $table) {
                $table->id(); // Default primary key
                $table->foreignId('users_id')
                    ->constrained('users', 'id') // Reference 'borrower_id'
                    ->onDelete('cascade'); // Handle cascading deletes
                $table->foreignId('copy_id')
                    ->constrained('copies', 'id') // Reference 'copy_id'
                    ->onDelete('cascade');
                $table->foreignId('status_id')
                    ->constrained('status', 'id') // Reference 'copy_id'
                    ->onDelete('cascade')
                    ->default(1);
                $table->date('date_borrowed');
                $table->date('return_date')->nullable();
                $table->timestamps();
            });
    }

    /**
     * Reverse the migrations.
     */ 
    public function down(): void
    {
        Schema::dropIfExists('borrowed_books');
    }
};
