<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TestController extends Controller
{
    public function welcome()
    {
        return response() -> json(['message' => 'Hello!']);
    }
}
