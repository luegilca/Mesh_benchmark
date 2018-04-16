import java.util.TreeSet;
import java.util.Arrays;

public class Mesh {

  PShape shape;
  float scaleFactor;
  /**
   * 0 - Vertex-Vertex representation
   */
  int repMode;

  //It is easy to know the number of vertices without traversing the whole file
  //there is always a comment after all "v" definitions with the vertex count
  int vertexCount;

  PVector vertices[];
  TreeSet<Integer> edges[];
  
  /**
  *  if vertex 1 is connected with vertices 2, 3 and 4, the representation in
  *  HashMap is: <1, <2, 3, 4>>
  **/
  HashMap<Integer, TreeSet<Integer>> faces = new HashMap<Integer, TreeSet<Integer>>( );
  
  // Representation: 	Vertex 1:  Pvector(x1, y1, z1) -> 1
  //					Vertex 2:  Pvector(x2, y2, z2) -> 2, and so on..						
  HashMap<PVector, Integer> mappedVertices = new HashMap<PVector, Integer>();

  // Representation: 	Face 1 is conformed by vertices 1, 2 and 3, so: 1 -> "1 2 3"
  //					Face 2 is conformed by vertices 4, 5 and 3, so: 2 -> "4 5 3"
  HashMap<Integer, String> faceList = new HashMap<Integer, String>( );

  HashMap<PVector, String> vertexList = new HashMap<PVector, String>( );
  String filePath;
  
  
  public Mesh( int repMode, float scaleFactor, PShape shape, String file) {
    vertexCount=0;
    for(int i=0; i<shape.getChildCount();i++){
      vertexCount+=shape.getChild(i).getVertexCount(); 
    }
    filePath=file;
    vertices= new PVector[ vertexCount ];
    edges= new TreeSet[ vertexCount ];
    this.repMode = repMode;
    this.scaleFactor = scaleFactor;
    this.shape = shape;
    init( );
  }

  public void getMesh( ) {
  	//VV on inmediate mode
	if( repMode == 0 ) {
	  vertexVertex( );
	}
	//FV on inmediate mode
	else if( repMode == 1 ){
	  faceVertex( );
	}
    //Winged-Edge on inmediate mode
    else{
    }
  }

  private void init( ) {
    processFile( shape );
  }

  private void processFile( PShape shape ) {
    String[] lines = loadStrings( filePath );
    int skip = 0;

    //initializing TreeSet
    for ( int i = 0; i < edges.length; i++ ) {
      edges[ i ] = new TreeSet<Integer>( );
    }

    for( int i = 0; i < lines.length; i++ ) {
      //splitted by one or more spaces
      String[] token = lines[ i ].split( "[ ]+" );
      //is a vertex definition?
      if( token[ 0 ].equals( "v" ) ) {
        PVector vertex = new PVector( Float.parseFloat( token[ 1 ] ),
                                      Float.parseFloat( token[ 2 ] ),
                                      Float.parseFloat( token[ 3 ] ) );
        vertices[ i - skip ] = vertex;
        mappedVertices.put( vertex, i - skip + 1 );
      }
      //is a face definition?
      else if( token[ 0 ].equals( "f" ) ) {
        for( int j = 1; j < token.length; j++ ) {
          //vertex number
          int vertex = Integer.parseInt( token[ j ] );
          
          if( !faces.containsKey( vertex ) ) {
            TreeSet<Integer> links = new TreeSet<Integer>( );
            faces.put( vertex, links );
          }          
          
          TreeSet<Integer> verticesLinked = faces.get( vertex );
          //first vertex on face definition, linked with last one
          if( j == 1 ) {
            verticesLinked.add( Integer.parseInt( token[ token.length - 1 ] ) );
            verticesLinked.add( Integer.parseInt( token[ j + 1 ] ) );
          }
          //last vertex on face definition, linked with first one
          else if( j == token.length - 1 ) {
            verticesLinked.add( Integer.parseInt( token[ 1 ] ) );
            verticesLinked.add( Integer.parseInt( token[ j - 1 ] ) );
          }
          //other vertices
          else {
            verticesLinked.add( Integer.parseInt( token[ j + 1 ] ) );
            verticesLinked.add( Integer.parseInt( token[ j - 1 ] ) ); 
          }
          
          faces.put( vertex, verticesLinked );
        }
      }
      else {
        skip++;
      }
      //println(Arrays.toString(vertices));
      //println(Arrays.asList(faces));
    }
    
    int faceCounter = 1;
    for ( int i = 0; i < shape.getChildCount( ); i++ ) {
        PShape f = shape.getChild( i );
        for ( int j = 0; j < f.getVertexCount( ); j++ ) {
          PVector a = f.getVertex( j );
          if ( faceList.get( faceCounter ) == null )
            faceList.put( faceCounter, "" );
          faceList.put( faceCounter, faceList.get( faceCounter ) + mappedVertices.get( a ) + " " );
          if ( vertexList.get( a ) == null )
            vertexList.put( a, "" );
          vertexList.put( a, vertexList.get( a ) + faceCounter + " " );
        }
        faceCounter++;
    }
    
  }
  
  // Traverse Vertex-Vertex data structure
  private void vertexVertex( ) {    
    for( int face : faces.keySet( ) ){
      beginShape();
      PVector v = vertices[ face - 1 ];
      vertex( scaleFactor * v.x, scaleFactor * v.y, scaleFactor * v.z ); //<>//
      for( int vertex : faces.get( face ) ){
        v = vertices[ vertex - 1 ];
        vertex( scaleFactor * v.x, scaleFactor * v.y, scaleFactor * v.z );
      }
      endShape();
    }    
  }
  
  // Traverse Face-Vertex data structure
  private void faceVertex( ) {
    for ( Integer k : faceList.keySet( ) ) {
      String faceVertices[] = faceList.get( k ).split( " " );
      beginShape( );
      for ( int i = 0; i < faceVertices.length; i++ ) {
        int vertex = Integer.parseInt( faceVertices[ i ] );
        PVector v = vertices[ vertex - 1 ];
        vertex( scaleFactor * v.x , scaleFactor * v.y, scaleFactor * v.z );
      }
      int vertex = Integer.parseInt( faceVertices[ 0 ] );
      PVector v = vertices[ vertex - 1 ];
      vertex( scaleFactor * v.x , scaleFactor * v.y, scaleFactor * v.z );
      endShape( );
    }
  }
}