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
        Schema::create('copies', function (Blueprint $table) {
            $table->id('copy_id'); // Custom primary key
            $table->foreignId('book_id')
                  ->constrained('books', 'book_id') // Reference 'book_id' in 'books'
                  ->onDelete('cascade'); // Handle cascading deletes
            $table->date('date_encoded')->default(now());
            $table->string('status', 50);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('copies');
    }
};
