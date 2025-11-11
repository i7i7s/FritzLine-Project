# 🔧 Backend Fix Required: Train Sorting

## ❌ Current Issue
Trains in `/search` endpoint are not sorted by departure time, causing incorrect display order in the app.

### Example Problem:
```
Current Order (Wrong):
- Fajar Utama Solo: 05:40
- Mataram: 21:40  
- Gayabaru Malam Selatan: 11:10

Expected Order (Correct):
- Fajar Utama Solo: 05:40
- Gayabaru Malam Selatan: 11:10
- Mataram: 21:40
```

---

## ✅ Solution

### Update Backend API Endpoint: `/search`

**File**: `index.js` (or `index_updated.js`)

**Find this code** (around line 20-40):
```javascript
app.get('/search', async (req, res) => {
  const { from, to } = req.query;
  
  const query = `
    SELECT DISTINCT
      t.id_kereta,
      t.nama_kereta,
      t.kelas,
      s1.jam_berangkat as jadwalBerangkat,
      s2.jam_tiba as jadwalTiba,
      t.harga,
      t.durasi,
      ...
    FROM trains t
    JOIN stops s1 ON t.id_kereta = s1.id_kereta
    JOIN stops s2 ON t.id_kereta = s2.id_kereta
    WHERE s1.kode_stasiun = ? 
      AND s2.kode_stasiun = ?
  `;
```

**Add ORDER BY clause**:
```javascript
app.get('/search', async (req, res) => {
  const { from, to } = req.query;
  
  const query = `
    SELECT DISTINCT
      t.id_kereta,
      t.nama_kereta,
      t.kelas,
      s1.jam_berangkat as jadwalBerangkat,
      s2.jam_tiba as jadwalTiba,
      t.harga,
      t.durasi,
      ...
    FROM trains t
    JOIN stops s1 ON t.id_kereta = s1.id_kereta
    JOIN stops s2 ON t.id_kereta = s2.id_kereta
    WHERE s1.kode_stasiun = ? 
      AND s2.kode_stasiun = ?
    ORDER BY s1.jam_berangkat ASC
  `;
```

---

## 🔍 Alternative: Check MySQL Table

If your backend uses `TIME` datatype for `jam_berangkat`, MySQL should sort correctly with:
```sql
ORDER BY s1.jam_berangkat ASC
```

If stored as `VARCHAR`, you might need:
```sql
ORDER BY CAST(s1.jam_berangkat AS TIME) ASC
```

---

## ✅ Flutter Side Already Fixed

The Flutter app now also sorts trains client-side as a fallback:

**File**: `lib/app/modules/detail_jadwal/controllers/detail_jadwal_controller.dart`

```dart
filteredTrains.sort((a, b) {
  String timeA = a['jadwalBerangkat'] ?? '00:00';
  String timeB = b['jadwalBerangkat'] ?? '00:00';
  
  var partsA = timeA.split(':');
  var partsB = timeB.split(':');
  
  if (partsA.length >= 2 && partsB.length >= 2) {
    int hourA = int.parse(partsA[0]);
    int minuteA = int.parse(partsA[1]);
    int hourB = int.parse(partsB[0]);
    int minuteB = int.parse(partsB[1]);
    
    if (hourA != hourB) {
      return hourA.compareTo(hourB);
    }
    return minuteA.compareTo(minuteB);
  }
  
  return timeA.compareTo(timeB);
});
```

**Note**: Changed from `jamBerangkat` to `jadwalBerangkat` to match API response field name.

---

## 🧪 Testing After Backend Update

### Test Case 1: PSE → SLO (Pasar Senen → Solo Balapan)
```
Expected Order:
1. Fajar Utama Solo: 05:40
2. Gayabaru Malam Selatan: 11:10
3. Mataram: 21:40
```

### Test Case 2: YK → JKT (Yogyakarta → Jakarta)
```
Expected Order:
(Sorted by departure time, earliest first)
```

### Test Case 3: Today's Date with 30-Min Filter
```
Current time: 11:16
Expected Result:
- Trains departing before 11:46 = Hidden
- Trains departing after 11:46 = Shown (sorted)
```

---

## 📝 Deployment Steps

1. Update `index.js` on local machine
2. Add `ORDER BY s1.jam_berangkat ASC` to the query
3. Test locally: `node index.js`
4. Deploy to Railway
5. Test Flutter app with the updated endpoint
6. Verify sorting is correct

---

## 🚀 Current Status

- ✅ Flutter sorting: **FIXED** (client-side fallback)
- ⏳ Backend sorting: **PENDING** (needs update on Railway)
- ✅ Field name mismatch: **FIXED** (`jamBerangkat` → `jadwalBerangkat`)

---

## 📌 Priority: HIGH
Sorting is critical for user experience. Users expect trains to be displayed in chronological order.
