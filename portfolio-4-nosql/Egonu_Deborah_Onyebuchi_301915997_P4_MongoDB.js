// NaijaMart product catalogue in MongoDB.   Run: mongosh naijamart Egonu_Deborah_Onyebuchi_301915997_P4_MongoDB.js
db = db.getSiblingDB('naijamart');
db.products.drop();

db.createCollection('products', { validator: { $jsonSchema: {
  bsonType: 'object', required: ['sku','name','category','price'],
  properties: { sku:{bsonType:'string'}, name:{bsonType:'string'}, category:{bsonType:'string'},
                price:{bsonType:['double','int','long'], minimum:1}, attributes:{bsonType:'object'},
                reviews:{bsonType:'array'} } } } });
db.products.createIndex({ sku: 1 }, { unique: true });
db.products.createIndex({ category: 1, price: 1 });
db.products.createIndex({ 'attributes.ram_gb': 1 });

db.products.insertMany([
  { sku:'PH-001', name:'Tecno Spark 20', category:'Phones', price:145000,
    attributes:{ ram_gb:8, storage_gb:128, colour:'Black' },
    reviews:[{ user:'Ada', rating:5, text:'Great battery' },{ user:'Tunde', rating:4 }] },
  { sku:'PH-002', name:'Phone Case', category:'Phones', price:3500,
    attributes:{ colour:'Clear', fits:'Spark 20' }, reviews:[{ user:'Chi', rating:4 }] },
  { sku:'SH-001', name:'Ankara Shirt', category:'Fashion', price:15000,
    attributes:{ size:'L', colour:'Green', material:'Cotton' }, reviews:[{ user:'Bola', rating:5 }] },
  { sku:'BK-001', name:'Database Systems Concepts', category:'Books', price:32000,
    attributes:{ author:'Silberschatz', pages:1376 }, reviews:[] }
]);

print('--- 1. products with different attributes in one collection');
db.products.find({}, { _id:0, sku:1, attributes:1 }).forEach(printjson);

print('--- 2. filter on a nested attribute');
db.products.find({ category:'Phones', 'attributes.ram_gb':{ $gte:8 } }, { _id:0, name:1, price:1 }).forEach(printjson);

print('--- 3. aggregation: average rating per category');
db.products.aggregate([
  { $unwind:{ path:'$reviews', preserveNullAndEmptyArrays:true } },
  { $group:{ _id:'$category', avgRating:{ $avg:'$reviews.rating' }, reviewCount:{ $sum:{ $cond:[{ $ifNull:['$reviews',false] },1,0] } } } },
  { $sort:{ _id:1 } }
]).forEach(printjson);

print('--- 4. update: add a review');
db.products.updateOne({ sku:'PH-001' }, { $push:{ reviews:{ user:'Emeka', rating:5 } } });
printjson(db.products.findOne({ sku:'PH-001' }, { _id:0, name:1, reviews:1 }));

print('--- 5. index used by the category + price query');
const plan = db.products.find({ category:'Phones', price:{ $lt:150000 } }).explain('executionStats');
printjson({ stage: plan.queryPlanner.winningPlan.inputStage ? plan.queryPlanner.winningPlan.inputStage.stage : plan.queryPlanner.winningPlan.stage,
            docsExamined: plan.executionStats.totalDocsExamined });
