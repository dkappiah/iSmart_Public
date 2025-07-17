<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    
    protected $fillable = [
        'user_id',
        'type', 
        'amount',
        'description',
        'status', 
        'related_user_id', 
    ];

    
    protected $casts = [
        'amount' => 'float', 
    ];

    
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    
    public function relatedUser()
    {
        return $this->belongsTo(User::class, 'related_user_id');
    }
}