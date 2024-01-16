---
title: Basic → Controllers
---

# Controllers

`Controller` are a great way to group different logic of your application, and most Controllers have the capability to accept multiple requests and respond as needed.

Spry allows you to register routes by implementing a `RouteCollection` in your controller, so you can register routes in your controller.

Now, let's create a `TodosController` to handle routing for our Todo application.

```dart
class TodosController implements RouteCollection {
    @override
    void boot(RoutesBuilder routes) {
        final todos = routes.group('/todos');

        todos.get('/', index);
        todos.post('/', create);

        todos.group(':id', (todo) {
            todo.get('/', show);
            todo.put('/', update);
            todo.delete('/', delete);
        });
    }

    /// Index todos.
    Future<Iterable<Todo>> index(HttpRequest request) {
        return Todo.all();
    }

    /// Create a todo.
    Future<Todo> create(HttpRequest request) async {
        return Todo.create(await request.json());
    }

    /// Show a todo.
    Future<Todo> show(HttpRequest request) async {
        final id = request.param.get('id');
        final todo = await Todo.find(id);

        if (todo == null) {
            throw Abort(404, 'Todo not found.');
        }

        return todo;
    }

    /// Update a todo.
    Future<Todo> update(HttpRequest request) async {
        final id = request.param.get('id');
        final todo = await Todo.find(id);

        if (todo == null) {
            throw Abort(404, 'Todo not found.');
        }

        return todo.update(await request.json());
    }

    /// Delete a todo.
    Future<void> delete(HttpRequest request) async {
        final id = request.param.get('id');

        await Todo.delete(id);
    }
}
```

Then, we just need to register the `TodosController` into our application and it's ready to use.

```dart
app.register(TodosController());
```
