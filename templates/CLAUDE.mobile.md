
---

## Mobile Engineering Standards

### Core Principles
- **Offline-first**: the app must function without a network — sync when connected
- **Optimistic UI**: apply state changes immediately; roll back on failure
- **Battery-aware**: batch network requests; avoid polling — use push / WebSocket
- **Crash-free target**: >99.5% crash-free sessions measured via Crashlytics/Sentry

### State Management
```
UI Layer (components/screens)
    ↕ observe state
State Layer (ViewModel/BLoC/Zustand store)
    ↕ call use cases
Domain Layer (use cases, entities)
    ↕ abstract interfaces
Data Layer (repositories, remote/local sources)
```
- State flows down, events flow up — unidirectional data flow always
- ViewModels hold UI state, not raw domain models — map at the boundary
- Never call network or DB from a composable/widget — go through the state layer

### Offline Sync
- Local-first write: write to local DB immediately, queue sync operation
- Conflict resolution strategy defined before any sync is implemented:
  - **Last-write-wins**: simple, acceptable for non-collaborative data
  - **Server-wins**: for data owned by server (catalog, pricing)
  - **CRDT**: for collaborative editing (docs, notes)
- Use sync queue table in local DB: `pending_syncs(id, entity_type, entity_id, operation, payload, attempts, created_at)`
- Exponential backoff on sync retries — `min(2^n × 1s, 60s)` with jitter

### Navigation
- Deep link every screen — URL scheme defined upfront: `app://orders/{id}`
- Handle back stack carefully on Android — test with physical back button
- Modal vs push navigation: modals for transient tasks; push for drill-down

### Performance
- Lazy load heavy screens — code-split at route level
- List virtualization for >50 items — `RecyclerView` / `LazyColumn` / `FlatList`
- Image optimization: compressed assets, progressive loading, cache to disk
- Measure with profiler, not assumptions — Instruments (iOS), Android Profiler, Flipper

### React Native Specific
```typescript
// Avoid anonymous functions in render — stable references
const handlePress = useCallback(() => dispatch(action()), [dispatch]);

// Memo expensive computations
const sorted = useMemo(() => items.sort(byDate), [items]);

// Bridge heavy work off the JS thread
import { runOnJS, useSharedValue } from 'react-native-reanimated';
```
- `useCallback` / `useMemo` only where profiler confirms render overhead
- Avoid `useEffect` for derived state — compute during render or in the store
- Hermes engine enabled — required for production performance

### Flutter Specific
```dart
// BLoC pattern
class OrderCubit extends Cubit<OrderState> {
  OrderCubit(this._repo) : super(OrderInitial());
  final OrderRepository _repo;

  Future<void> load(String id) async {
    emit(OrderLoading());
    final result = await _repo.get(id);
    result.fold(
      (err) => emit(OrderError(err.message)),
      (order) => emit(OrderLoaded(order)),
    );
  }
}
```
- `const` constructors everywhere possible — rebuild prevention is free
- `Riverpod` or `BLoC` for state — no `setState` beyond leaf widgets
- `freezed` for immutable data classes — sealed unions for state

### Testing
| Layer | Tool | What |
|---|---|---|
| Unit | `jest` / `flutter_test` | Domain logic, state reducers |
| Widget/Component | `@testing-library/react-native` / `flutter_test` | UI behavior |
| Integration | `Detox` / `integration_test` | Critical user flows on device |
| Visual regression | `Storybook` + `Chromatic` | Component appearance |
